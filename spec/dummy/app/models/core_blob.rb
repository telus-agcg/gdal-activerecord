class CoreBlob < ActiveRecord::Base
  belongs_to_resource :grower
  belongs_to_resource :farm
  belongs_to_resource :field
  belongs_to_resource :planting
  has_one_resource :organization, through: :grower
end
