class Product < ApplicationRecord
  has_many :line_items
  before_destroy :ensure_no_references

  validates :title, uniqueness: true, length: { minimum: 10 }
  validates :title, :description, :image_url, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :image_url, allow_blank: true, format: {
    with: %r{\.(gif|jpg|png)\z}i,
    message: 'must be a URL for GIF, JPG or PNG image.'
  }

  private

  def ensure_no_references
    unless line_items.empty?
      errors.add(:base, 'Line items exist for this product')
      throw :abort
    end
  end
end
