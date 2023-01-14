<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wp_mysite' );

/** Database username */
define( 'DB_USER', 'wp_mysite_user' );

/** Database password */
define( 'DB_PASSWORD', 'passwd' );

/** Database hostname */
define( 'DB_HOST', 'localhost' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         '/pcZ%QwJ::q6;esdE6ou>zk0B0YZ6jugx7EJ=z7fv&Kd<8C8>#1XGH-PV9efO1D0' );
define( 'SECURE_AUTH_KEY',  '.d<UNDNjqWYEsse*yti@!7FlwuK:g0w|cP#9/kR.aC!sTcDwv}dPl{R^$V>$AmnV' );
define( 'LOGGED_IN_KEY',    '8F]YJ=c!OmHF^}b@8l3CblOxTQN0f6,%H)[xD1$366!2I+HKnDWhF*|a]bSPo?/)' );
define( 'NONCE_KEY',        ';(fmq*~4HI`cqKIQ]/qx[E&51,ht.DSK,tDN!%=,51;$>]=bJWbSc#g2-hAa`A/H' );
define( 'AUTH_SALT',        '&wJ/U8n<Oelsm:;Hjy8*(!bSHk -{p89[C=j8xIf[0n*pwvY-W!2lDH_>]cV:L$(' );
define( 'SECURE_AUTH_SALT', 'h,JP`z03Iou>=8~vDSRfr#2Z{7XGw>Y4:M<$aqdQ.MTm5, ^C7&hT0bZq)]SAUj(' );
define( 'LOGGED_IN_SALT',   'M-:46nF`TloSY?K9#BWn1K1y:vvTQjJ}lMe`dd6{[{tuYN&BN%g;j,p*.$/?zKIp' );
define( 'NONCE_SALT',       '[+Cug@m4J=9W__y)e7685F&%v:n-ABu^usA6V`eqfA=b2NGAmqcJ6xF$/i!EQ]R ' );

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG', true );
/* Add any custom values between this line and the "stop editing" line. */

@ini_set('log_errors','On');

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';