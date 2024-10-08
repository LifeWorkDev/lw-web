class LogidzeInstall < ActiveRecord::Migration[5.0]
  require "logidze/migration"

  def up
    safety_assured do
      execute <<-SQL
        DO $$
          BEGIN
          EXECUTE 'ALTER DATABASE ' || quote_ident(current_database()) || ' SET logidze.disabled=' || quote_literal('');
          EXECUTE 'ALTER DATABASE ' || quote_ident(current_database()) || ' SET logidze.meta=' || quote_literal('');
          END;
        $$
        LANGUAGE plpgsql;
      SQL

      execute <<-SQL
        CREATE OR REPLACE FUNCTION logidze_version(v bigint, data jsonb, ts timestamp with time zone, blacklist text[] DEFAULT '{}') RETURNS jsonb AS $body$
          DECLARE
            buf jsonb;
          BEGIN
            buf := jsonb_build_object(
                     'ts',
                     (extract(epoch from ts) * 1000)::bigint,
                     'v',
                      v,
                      'c',
                      logidze_exclude_keys(data, VARIADIC array_append(blacklist, 'log_data'))
                     );
            IF coalesce(current_setting('logidze.meta', true), '') <> '' THEN
              buf := jsonb_set(buf, ARRAY['m'], current_setting('logidze.meta')::jsonb);
            END IF;
            RETURN buf;
          END;
        $body$
        LANGUAGE plpgsql;

        CREATE OR REPLACE FUNCTION logidze_snapshot(item jsonb, ts_column text, blacklist text[] DEFAULT '{}') RETURNS jsonb AS $body$
          DECLARE
            ts timestamp with time zone;
          BEGIN
            IF ts_column IS NULL THEN
              ts := statement_timestamp();
            ELSE
              ts := coalesce((item->>ts_column)::timestamp with time zone, statement_timestamp());
            END IF;
            return json_build_object(
              'v', 1,
              'h', jsonb_build_array(
                     logidze_version(1, item, ts, blacklist)
                   )
              );
          END;
        $body$
        LANGUAGE plpgsql;

        CREATE OR REPLACE FUNCTION logidze_exclude_keys(obj jsonb, VARIADIC keys text[]) RETURNS jsonb AS $body$
          DECLARE
            res jsonb;
            key text;
          BEGIN
            res := obj;
            FOREACH key IN ARRAY keys
            LOOP
              res := res - key;
            END LOOP;
            RETURN res;
          END;
        $body$
        LANGUAGE plpgsql;

        CREATE OR REPLACE FUNCTION logidze_compact_history(log_data jsonb) RETURNS jsonb AS $body$
          DECLARE
            merged jsonb;
          BEGIN
            merged := jsonb_build_object(
              'ts',
              log_data#>'{h,1,ts}',
              'v',
              log_data#>'{h,1,v}',
              'c',
              (log_data#>'{h,0,c}') || (log_data#>'{h,1,c}')
            );

            IF (log_data#>'{h,1}' ? 'm') THEN
              merged := jsonb_set(merged, ARRAY['m'], log_data#>'{h,1,m}');
            END IF;

            return jsonb_set(
              log_data,
              '{h}',
              jsonb_set(
                log_data->'h',
                '{1}',
                merged
              ) - 0
            );
          END;
        $body$
        LANGUAGE plpgsql;

        CREATE OR REPLACE FUNCTION logidze_logger() RETURNS TRIGGER AS $body$
          DECLARE
            changes jsonb;
            version jsonb;
            snapshot jsonb;
            new_v integer;
            size integer;
            history_limit integer;
            debounce_time integer;
            current_version integer;
            merged jsonb;
            iterator integer;
            item record;
            columns_blacklist text[];
            ts timestamp with time zone;
            ts_column text;
          BEGIN
            ts_column := NULLIF(TG_ARGV[1], 'null');
            columns_blacklist := COALESCE(NULLIF(TG_ARGV[2], 'null'), '{}');

            IF TG_OP = 'INSERT' THEN
              snapshot = logidze_snapshot(to_jsonb(NEW.*), ts_column, columns_blacklist);

              IF snapshot#>>'{h, -1, c}' != '{}' THEN
                NEW.log_data := snapshot;
              END IF;

            ELSIF TG_OP = 'UPDATE' THEN

              IF OLD.log_data is NULL OR OLD.log_data = '{}'::jsonb THEN
                snapshot = logidze_snapshot(to_jsonb(NEW.*), ts_column, columns_blacklist);
                IF snapshot#>>'{h, -1, c}' != '{}' THEN
                  NEW.log_data := snapshot;
                END IF;
                RETURN NEW;
              END IF;

              history_limit := NULLIF(TG_ARGV[0], 'null');
              debounce_time := NULLIF(TG_ARGV[3], 'null');

              current_version := (NEW.log_data->>'v')::int;

              IF ts_column IS NULL THEN
                ts := statement_timestamp();
              ELSE
                ts := (to_jsonb(NEW.*)->>ts_column)::timestamp with time zone;
                IF ts IS NULL OR ts = (to_jsonb(OLD.*)->>ts_column)::timestamp with time zone THEN
                  ts := statement_timestamp();
                END IF;
              END IF;

              IF NEW = OLD THEN
                RETURN NEW;
              END IF;

              IF current_version < (NEW.log_data#>>'{h,-1,v}')::int THEN
                iterator := 0;
                FOR item in SELECT * FROM jsonb_array_elements(NEW.log_data->'h')
                LOOP
                  IF (item.value->>'v')::int > current_version THEN
                    NEW.log_data := jsonb_set(
                      NEW.log_data,
                      '{h}',
                      (NEW.log_data->'h') - iterator
                    );
                  END IF;
                  iterator := iterator + 1;
                END LOOP;
              END IF;

              changes := hstore_to_jsonb_loose(
                hstore(NEW.*) - hstore(OLD.*)
              );

              new_v := (NEW.log_data#>>'{h,-1,v}')::int + 1;

              size := jsonb_array_length(NEW.log_data->'h');
              version := logidze_version(new_v, changes, ts, columns_blacklist);

              IF version->>'c' = '{}' THEN
                RETURN NEW;
              END IF;

              IF (
                debounce_time IS NOT NULL AND
                (version->>'ts')::bigint - (NEW.log_data#>'{h,-1,ts}')::text::bigint <= debounce_time
              ) THEN
                -- merge new version with the previous one
                new_v := (NEW.log_data#>>'{h,-1,v}')::int;
                version := logidze_version(new_v, (NEW.log_data#>'{h,-1,c}')::jsonb || changes, ts, columns_blacklist);
                -- remove the previous version from log
                NEW.log_data := jsonb_set(
                  NEW.log_data,
                  '{h}',
                  (NEW.log_data->'h') - (size - 1)
                );
              END IF;

              NEW.log_data := jsonb_set(
                NEW.log_data,
                ARRAY['h', size::text],
                version,
                true
              );

              NEW.log_data := jsonb_set(
                NEW.log_data,
                '{v}',
                to_jsonb(new_v)
              );

              IF history_limit IS NOT NULL AND history_limit = size THEN
                NEW.log_data := logidze_compact_history(NEW.log_data);
              END IF;
            END IF;

            return NEW;
          END;
          $body$
          LANGUAGE plpgsql;
      SQL
    end
  end

  def down
    safety_assured do
      execute <<-SQL
        DROP FUNCTION logidze_version(bigint, jsonb, timestamp with time zone, text[]) CASCADE;
        DROP FUNCTION logidze_exclude_keys(jsonb, text[]) CASCADE;
        DROP FUNCTION logidze_compact_history(jsonb) CASCADE;
        DROP FUNCTION logidze_snapshot(jsonb, text, text[]) CASCADE;
        DROP FUNCTION logidze_logger() CASCADE;
      SQL
    end
  end
end
