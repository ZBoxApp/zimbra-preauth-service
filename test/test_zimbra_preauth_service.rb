require 'test_helper'
require 'pp'

# Doc placeholder
class LdapTest < Minitest::Test
  def test_authenticate_user_should_return_false_without_data
    assert !ZimbraPreauthService.auth_user('admin@zboxapp.dev', '')
    assert !ZimbraPreauthService.auth_user('', '123')
    assert !ZimbraPreauthService.auth_user('kdkdkd', '123')
    assert !ZimbraPreauthService.auth_user
  end

  def test_return_false_if_wrong_credentials
    assert !ZimbraPreauthService.auth_user('admin@zboxapp.dev', '12345')
  end

  def test_return_false_if_right_credentials
    assert ZimbraPreauthService.auth_user('admin@zboxapp.dev', '12345678')
  end

  def test_return_domain_preauth_key_from_email
    key = '1c748459f79083be7a69bcec3e71523dffd778b1e7c86328dcd86f131605c279'
    result = ZimbraPreauthService.user_preauth_key('admin@zboxapp.dev')
    assert_equal key, result
  end

  def test_get_user_data_return_correct_data_from_email
    key = '33da59f8323e7bb82c1641bedc6ac276ae6a7f50011fe5b8c2c63da73ee7d004'
    u = ZimbraPreauthService.user_info('pato@itlinux.cl')
    assert_equal 'pbruna@itlinux.cl', u.email, 'email'
    assert_equal 'Bruna', u.last_name, 'sn'
    assert_equal 'Patricio', u.first_name, 'given_name'
    assert_equal key, u.preauth_token, 'token'
    assert_equal 'itlinux.cl', u.domain, 'domain'
    assert_equal 'itlinux_cl', u.default_team, 'token'
    assert u.mail_login_url, 'login url'
  end

end
