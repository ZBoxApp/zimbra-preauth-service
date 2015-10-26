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
    assert_equal '20151020182731', u.last_name, 'sn'
    assert_equal 'Patricio', u.first_name, 'given_name'
    assert_equal 'ITLinux', u.default_team, 'team_name'
    assert_equal key, u.preauth_token, 'token'
    assert_equal 'itlinux.cl', u.domain, 'domain'
    assert u.mail_login_url, 'login url'
    assert u.chat_enabled, 'Chat Enabled'
  end

  def test_chat_disabled_if_value_is_set_to_false
    u = ZimbraPreauthService.user_info('user2@customer1.dev')
    assert !u.chat_enabled, 'Chat Enabled'
  end

  def test_chat_disabled_if_value_empty
    u = ZimbraPreauthService.user_info('user1@customer1.dev')
    assert !u.chat_enabled, 'Chat Enabled'
  end

  def test_find_team_should_return_the_user_team_name
    u = ZimbraPreauthService.find_user('user1@customer1.dev')
    team_name = ZimbraPreauthService.find_team_name(u)
    assert_equal 'ZBox', team_name
  end

  def test_find_team_should_return_the_domain_team_name
    u = ZimbraPreauthService.find_user('user2@customer1.dev')
    team_name = ZimbraPreauthService.find_team_name(u)
    assert_equal 'Customer1', team_name
  end

  def test_find_team_should_raise_if_not_team_name
    u = ZimbraPreauthService.find_user('admin@zboxapp.dev')
    assert_raises(ZimbraPreauthService::Errors::MissingChatTeamName) {
      ZimbraPreauthService.find_team_name(u)
    }
  end

end
