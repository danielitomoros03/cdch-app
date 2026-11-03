# Respaldos de cdch-app en silenia

`cdch-respaldo` respalda la base y los archivos subidos, y renueva la base de ubicaciones
por IP de la bitácora. Corre una vez al día con cron, como root. El detalle de cada paso
está al comienzo del script.

## Dónde queda cada cosa

| Qué | Dónde | Cuántos se guardan |
|---|---|---|
| Base de datos, diaria | `/var/backups/cdch/diarios/cdch-db-AAAA-MM-DD.dump` | 30 |
| Base de datos, mensual | `/var/backups/cdch/mensuales/cdch-db-AAAA-MM.dump` | 12 |
| Archivos subidos, semanal | `/var/backups/cdch/archivos/cdch-archivos-AAAA-MM-DD.tar.gz` | 8 |
| Registro de cada corrida | `/var/log/cdch-respaldo.log` | — |
| Estado que muestra la app | `/var/lib/dokku/data/storage/cdch-app/respaldo-estado.json` | — |

Los respaldos tienen datos personales de los docentes: la carpeta es solo de root y no
se copian por WhatsApp ni por correo.

## Instalar o actualizar

Desde la carpeta del repo:

```bash
scp script/server/cdch-respaldo root@silenia-dokku:/usr/local/sbin/cdch-respaldo
ssh root@silenia-dokku 'chmod 700 /usr/local/sbin/cdch-respaldo'
```

Línea de cron (`crontab -e` como root):

```
30 2 * * * /usr/local/sbin/cdch-respaldo
```

## Restaurar

**Esto reemplaza la base de producción completa.** Primero se respalda la actual:

```bash
/usr/local/sbin/cdch-respaldo
dokku ps:stop cdch-app
dokku postgres:import cdch-db < /var/backups/cdch/diarios/cdch-db-AAAA-MM-DD.dump
dokku ps:start cdch-app
```

Los archivos subidos:

```bash
tar -xzf /var/backups/cdch/archivos/cdch-archivos-AAAA-MM-DD.tar.gz -C /var/lib/dokku/data/storage/cdch-app
```

Para revisar un respaldo sin tocar producción, se puede listar su contenido:

```bash
docker exec -i dokku.postgres.cdch-db pg_restore --list < /var/backups/cdch/diarios/cdch-db-AAAA-MM-DD.dump | head
```
