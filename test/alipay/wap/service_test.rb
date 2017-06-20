require 'test_helper'

class Alipay::Wap::ServiceTest < Minitest::Test
  def test_trade_create_direct_token
    token = 'REQUEST_TOKEN'
    body = <<-EOS
      res_data=
        <?xmlversion="1.0" encoding="utf-8"?>
        <direct_trade_create_res>
          <request_token>#{token}</request_token>
        </direct_trade_create_res>
      &partner=PID
      &req_id=REQ_ID
      &sec_id=MD5
      &service=alipay.wap.trade.create.direct
      &v=2.0
      &sign=SIGN
    EOS

    stub_request(
      :get,
      %r|https://wappaygw\.alipay\.com/service/rest\.htm.*|
    ).to_return(body: body)

    assert_equal token, Alipay::Wap::Service.trade_create_direct_token(
      req_data: {
        seller_account_name: 'account@example.com',
        out_trade_no: '1',
        subject: 'subject',
        total_fee: '0.01',
        call_back_url: 'https://example.com/call_back'
      }
    )
  end

  def test_auth_and_execute_url
    assert_equal 'https://wappaygw.alipay.com/service/rest.htm?service=alipay.wap.auth.authAndExecute&req_data=%3Cauth_and_execute_req%3E%3Crequest_token%3Etoken_test%3C%2Frequest_token%3E%3C%2Fauth_and_execute_req%3E&partner=1000000000000000&format=xml&v=2.0&sec_id=MD5&sign=3efe60d4a9b7960ba599da6764c959df', Alipay::Wap::Service.auth_and_execute_url(request_token: 'token_test')
  end

  def test_security_risk_detect
    stub_request(
      :post,
      %r|https://wappaygw\.alipay\.com/service/rest\.htm.*|
    ).to_return(
      body: ' '
    )

    params = {
      order_no: '1',
      order_credate_time: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
      order_category: 'TestCase^AlipayGem^Ruby',
      order_item_name: 'item',
      order_amount: '0.01',
      buyer_account_no: '2088123123',
      buyer_bind_mobile: '13600000000',
      buyer_reg_date: '1970-01-01 00:00:00',
      terminal_type: 'WAP'
    }

    options = {
      sign_type: 'RSA',
      key: TEST_RSA_PRIVATE_KEY
    }

    assert_equal ' ', Alipay::Wap::Service.security_risk_detect(params, options).body
  end
end
