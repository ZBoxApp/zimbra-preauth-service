# Zimbra PreAuth REST Service

`Zimbra PreAuth REST Service` es una simple aplicación Web que permite obtener una
`URL` de ingreso al Webmail de Zimbra usando `PreAuth Keys`.

Además de la URL de ingreso, la aplicación entrega una respuesta `JSON` con
la siguiente información:

* `email`, dirección de correo real del usuario, no un alias si usó el alias para autenticarse
* `last_name` y `first_name`, se explican solos
* `preauth_token`, es el token del dominio
* `domain`, es el dominio real,
* `default_team`, nombre del equipo de chat basado en el dominio
* `mail_login_url`, URL para ingresar directamente al Webmail


Por ejemplo:

```
$ curl --data 'email=admin@zboxapp.dev&password=12345678' http://10.211.55.38:9292/login
```

responde con

```json
{
  "email": "admin@zboxapp.dev",
  "last_name": "admin",
  "first_name": null,
  "preauth_token": "1c748459f79083be7a69bcec3e71523dffd778b1e7c86328dcd86f131605c279",
  "domain": "zboxapp.dev",
  "default_team": "zboxapp_dev",
  "mail_login_url": "https://mail.zboxapp.com/service/preauth?account=admin@zboxapp.dev&timestamp=1445280915287&preauth=2fda92083f5fe2438adf2872e42c78c95b851248&expires=0"
}
```

## Uso imagen Docker

La aplicación necesita que le pases las siguientes variables de entorno para funcionar:

* `ldap_host`, la dirección IP de un servidor LDAP de Zimbra.
* `ldap_port`, el puerto en que escucha el LDAP.
* `ldap_binddn`, usuario con permisos de conexión al LDAP.
* `ldap_passwd`, clarito no?
* `mail_host`, nombre que se usa en la URL si el dominio no tiene `virtual_host`.

Por ejemplo puedes correr con Docker ejecutando:

```
$ docker run -p 9292:9292 -e ldap_host=192.168.50.10 \
  -e ldap_port=389 \
  -e ldap_binddn='uid=zimbra,cn=admins,cn=zimbra' \
  -e ldap_passwd='12345678' \
  -e mail_host='mail.zboxapp.com' \
  pbruna/zbox_zimbra_preauth
```

El caso de **mail_host** es para crear la URL de ingreso cuando el cliente no tiene un dominio propio de ingreso. Hay algunos clientes que ingresan al Webmail usando un
nombre de dominio propio, por ejemplo: `webmail.acme.com`.

También puedes clonar el repo y hacer como gustes!!!


## Sobre Zimbra PreaAuth
En el fondo es una forma de no tener que validar al usuario más de una vez.
Pero mejor lee la documentación: https://wiki.zimbra.com/wiki/Preauth

## Contributing

1. Fork it ( https://github.com/zboxapp/zimbra-preauth-service/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
