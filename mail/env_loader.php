<?php
function cargarEnv($ruta = null)
{
    if ($ruta === null) {
        $ruta = __DIR__ . '/.env';
    }

    if (!file_exists($ruta)) {
        throw new Exception('.env file not found en ' . $ruta);
    }

    $lineas = file($ruta, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

    foreach ($lineas as $linea) {
        if (strpos(trim($linea), '#') === 0) {
            continue;
        }

        if (!strpos($linea, '=')) {
            continue;
        }

        list($clave, $valor) = explode('=', $linea, 2);

        $clave = trim($clave);
        $valor = trim($valor, "'\"");

        putenv("$clave=$valor");
        $_ENV[$clave] = $valor;
        $_SERVER[$clave] = $valor;
    }
}
