<?php

// Set IP correctly when being proxied
$_SERVER['REMOTE_ADDR'] = $_SERVER['X-Real-IP'];

// Set SSL Status correctly when being proxied
if ($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['REQUEST_SCHEME'] = 'https';
}
