require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    @order = orders(:one)
  end

  test "visiting the index" do
    visit orders_url
    assert_selector "h1", text: "Orders"
  end

  test "should update Order" do
    visit order_url(@order)
    click_on "Edit this order", match: :first

    fill_in "Address", with: @order.address
    fill_in "E-mail", with: @order.email
    fill_in "Name", with: @order.name
    page.select "Check", from: "Pay Type"
    click_on "Place Order"

    assert_text "Order was successfully updated"
    click_on "Back"
  end

  test "should destroy Order" do
    visit order_url(@order)
    click_on "Destroy this order", match: :first

    assert_text "Order was successfully destroyed"
  end

  test "check dynamic fields" do
    visit store_index_url

    click_on 'Add to Cart', match: :first
    click_on 'Checkout'

    assert has_no_field? 'Routing #'
    assert has_no_field? 'Account #'
    assert has_no_field? 'Credit card #'
    assert has_no_field? 'Expiry'
    assert has_no_field? 'PO #'

    page.select 'Check', from: 'Pay Type'

    assert has_field? 'Routing #'
    assert has_field? 'Account #'
    assert has_no_field? 'CC #'
    assert has_no_field? 'Expiry'
    assert has_no_field? 'PO #'

    page.select 'Credit Card', from: 'Pay Type'

    assert has_no_field? 'Routing #'
    assert has_no_field? 'Account #'
    assert has_field? 'CC #'
    assert has_field? 'Expiry'
    assert has_no_field? 'PO #'

    page.select 'Purchase Order', from: 'Pay Type'

    assert has_no_field? 'Routing #'
    assert has_no_field? 'Account #'
    assert has_no_field? 'CC #'
    assert has_no_field? 'Expiry'
    assert has_field? 'PO #'
  end

  test "check order and delivery" do
    LineItem.delete_all
    Order.delete_all

    visit store_index_url
    visit store_index_url

    click_on 'Add to Cart', match: :first
    click_on 'Checkout'

    fill_in 'Name', with: 'Dave Thomas'
    fill_in 'Address', with: '123 Main Street'
    fill_in 'E-mail', with: 'dave@example.com'

    page.select 'Check', from: 'Pay Type'
    fill_in 'Routing #', with: '123456'
    fill_in 'Account #', with: '987654'

    click_button 'Place Order'
    assert_text "Thank you for your order."

    perform_enqueued_jobs
    perform_enqueued_jobs
    assert_performed_jobs 2

    orders = Order.all
    assert_equal 1, orders.size

    order = Order.first
    assert_equal 'Dave Thomas', order.name
    assert_equal '123 Main Street', order.address
    assert_equal 'dave@example.com', order.email
    assert_equal 'Check', order.pay_type
    assert_equal 1, order.line_items.size

    mail = ActionMailer::Base.deliveries.last
    assert_equal ['dave@example.com'], mail.to
    assert_equal 'from@example.com', mail[:from].value
    assert_equal 'Pragmatic Store Order Confirmation', mail.subject
  end
end
