# Do it this way to get gem models that inherit from ActiveRecord::Base instead of ApplicationRecord
ActiveRecord::Base.nilify_blanks before: :validation
