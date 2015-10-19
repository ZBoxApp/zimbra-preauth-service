require 'test_helper'
require 'pp'

class ConfigTest < Minitest::Test

  def test_config_ldap_host
    ENV.delete 'ldap_host'
    assert_raises(ZimbraPreauthService::Errors::LdapHost) {
      ZimbraPreauthService.ldap_host
    }
  end

  def test_config_ldap_port
    ENV.delete 'ldap_port'
    assert_raises(ZimbraPreauthService::Errors::LdapPort) {
      ZimbraPreauthService.ldap_port
    }
  end

  def test_config_ldap_user
    ENV.delete 'ldap_binddn'
    assert_raises(ZimbraPreauthService::Errors::LdapBinddn) {
      ZimbraPreauthService.ldap_binddn
    }
  end

  def test_config_ldap_passwd
    ENV.delete 'ldap_passwd'
    assert_raises(ZimbraPreauthService::Errors::LdapPasswd) {
      ZimbraPreauthService.ldap_passwd
    }
  end

  def test_config_defaul_host
    ENV.delete 'zbox_default_host'
    assert_raises(ZimbraPreauthService::Errors::MailHost) {
      ZimbraPreauthService.mail_host
    }
  end

end
