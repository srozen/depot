require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "received" do
    mail = OrderMailer.received(orders(:one))
    assert_equal "Pragmatic Store Order Confirmation", mail.subject
    assert_equal ["dave@example.com"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match /1 x product_title_two/, mail.body.encoded
  end

  test "shipped" do
    mail = OrderMailer.shipped(orders(:one))
    assert_equal "Pragmatic Store Order Shipped", mail.subject
    assert_equal ["dave@example.com"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match %r(
	      <td[^>]*>1<\/td>\s*
	      <td>&times;<\/td>\s*
	      <td[^>]*>\s*product_title_two\s*</td>
	    )x, mail.html_part.body.decoded
  end

end
