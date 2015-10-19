require 'net/ldap'
require 'ostruct'
require 'date'
require 'openssl'

# Doc placeholder
module ZimbraPreauthService

  class << self
    include OpenSSL

    # Estas son las variables de entorno
    # de conexion para LDAP 'ldap_XXX'
    %w(host port binddn passwd).each do |conf|
      error = "ZimbraPreauthService::Errors::Ldap#{conf.capitalize}"
      define_method "ldap_#{conf}" do
        fail Object.const_get error if ENV["ldap_#{conf}"].nil?
        ENV["ldap_#{conf}"]
      end
    end

    def mail_host
      fail ZimbraPreauthService::Errors::MailHost if ENV['mail_host'].nil?
      ENV['mail_host']
    end

    def valid_credentials?(user = '', password = '')
      return false unless user && password
      return false if user.size < 1 || password.size < 1
      auth_user(user, password)
    end

    def auth_user(user = '', password = '')
      # should be an email
      return false unless user =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
      client.bind_as(
        # get ldap base from email domain
        # in zimbra is like dc=itlinux,dc=cl
        base: user.split(/@/)[1].split(/\./).map { |d| "dc=#{d}" }.join(','),
        filter: "(mail=#{user})",
        password: password
      )
    end

    def build_login_url(login_email, preauth_token)
      tmstmp = DateTime.now.strftime('%Q')
      preauth = compute_preauth(login_email, preauth_token, tmstmp)
      mail_host = find_mail_host(login_email)
      params = "account=#{login_email}&timestamp=#{tmstmp}&preauth=#{preauth}"
      'https://' + mail_host + '/service/preauth?' + params + '&expires=0'
    end

    def compute_preauth(login_email, preauth_token, timestamp)
      plaintext = "#{login_email}|name|0|#{timestamp}"
      hmacd = HMAC.new(preauth_token, OpenSSL::Digest.new('sha1'))
      hmacd.update(plaintext)
      hmacd.to_s
    end

    def client
      ldap = Net::LDAP.new
      ldap.host = ZimbraPreauthService.ldap_host
      ldap.port = ZimbraPreauthService.ldap_port
      ldap.auth ZimbraPreauthService.ldap_binddn, ZimbraPreauthService.ldap_passwd
      ldap
    end

    def user_info(email)
      user = find_user(email)
      login_email = user.zimbramaildeliveryaddress.first
      preauth_token = user_preauth_key(login_email)
      OpenStruct.new(
        email: login_email,
        last_name: ldap_data(user['sn']),
        first_name: ldap_data(user['givenname']),
        preauth_token: preauth_token,
        domain: login_email.split(/@/)[1],
        default_team: login_email.split(/@/)[1].gsub(/\./, '_'),
        mail_login_url: build_login_url(login_email, preauth_token)
      )
    end

    def find_user(email)
      filter = Net::LDAP::Filter.eq('mail', email)
      base = email.split(/@/)[1].split(/\./).map { |d| "dc=#{d}" }.join(',')
      r = client.search( base: base, filter: filter).first
      fail ZimbraPreauthService::Errors::UserNotFound if r.nil?
      r
    end

    def find_domain(domain_name)
      filter = Net::LDAP::Filter.eq('zimbraDomainName', domain_name)
      base = 'dc=' + domain_name.split(/\./).last.to_s
      r = client.search( base: base, filter: filter).first
      fail ZimbraPreauthService::Errors::DomainNotFound if r.nil?
      r
    end

    def find_mail_host(email)
      domain = find_domain(email.split(/@/)[1])
      mail_host = domain['zimbravirtualhostname']
      return ZimbraPreauthService.mail_host if mail_host.empty?
      mail_host.first
    end

    def ldap_data(data)
      return '' if data.nil?
      return data.first if data.is_a?Array
      data
    end

    def user_preauth_key(email)
      domain_name = email.split(/@/)[1]
      domain = find_domain(domain_name)
      r = domain['zimbrapreauthkey']
      fail ZimbraPreauthService::Errors::MissingPreauthKey if r.empty?
      r.first
    end

  end

  module Errors
    class LdapHost < StandardError; end
    class LdapPort < StandardError; end
    class LdapBinddn < StandardError; end
    class LdapPasswd < StandardError; end
    class MissingPreauthKey < StandardError; end
    class UserNotFound < StandardError; end
    class DomainNotFound < StandardError; end
    class MailHost < StandardError; end
  end
end
