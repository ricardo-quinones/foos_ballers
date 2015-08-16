class Rating < ActiveRecord::Base
  belongs_to :player
  belongs_to :match
  belongs_to :previous_rating, class_name: 'Rating'
end
