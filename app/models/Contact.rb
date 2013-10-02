class Contact < ActiveRecord::Base
  attr_accessible :phone_number, :name, :user_id

  belongs_to :user, dependent: :destroy
  has_and_belongs_to_many :groups

  validates :name, :phone_number, presence: true
  validates :phone_number, phone: true

  before_save :sanitize_number

  def sanitize_number
    self.phone_number = "+" + Phonelib.parse(self.phone_number).sanitized
  end
end
