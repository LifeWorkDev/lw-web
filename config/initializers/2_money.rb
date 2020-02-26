Money.default_currency = :usd
Money.rounding_mode = BigDecimal::ROUND_HALF_UP
Money.locale_backend = :i18n

class Money
  def as_json(*)
    {
      amount: to_s,
      formatted_amount: format,
      currency: {
        code: currency.iso_code,
        symbol: currency.symbol,
      },
    }
  end
end
