require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test 'product attributes must not be empty' do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test 'product price must be positive' do
    product = products(:one)

    product.price = -1
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'], product.errors[:price]

    product.price = 0
    assert_equal ['must be greater than or equal to 0.01'], product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  test 'image_url' do
    product = products(:one)
    valid_urls = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://a.b.c/x/y/z/fred.gif }
    invalid_urls = %w{ fred.doc fred.gif/more fred.gif.more }

    valid_urls.each do |url|
      product.image_url = url
      assert product.valid?, "#{url} must be valid"
    end

    invalid_urls.each do |url|
      product.image_url = url
      refute product.valid?, "#{url} must be invalid"
    end
  end

  test 'product is not valid without a unique title' do
    product = Product.new(title: products(:one).title, description: 'a', price: 1, image_url: 'lorem.png')
    assert product.invalid?
    assert_equal ["has already been taken"], product.errors[:title]
  end
end
