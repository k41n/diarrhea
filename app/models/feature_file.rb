class FeatureFile < ActiveRecord::Base
  has_many :scenarios, :dependent => :destroy
  belongs_to :run
end
