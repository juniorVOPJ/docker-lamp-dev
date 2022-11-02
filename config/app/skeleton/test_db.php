<?php
$link = mysqli_connect("database", "root", $_ENV['MYSQL_ROOT_PASSWORD'], null);

if (!$link) {
    echo "Erro: Impossível conectar com MySql." . PHP_EOL;
    echo "Debug erro: " . mysqli_connect_errno() . PHP_EOL;
    echo "Debug erro: " . mysqli_connect_error() . PHP_EOL;
    exit;
}

echo "Successo: A conexão com o Banco de Dados está funcionando! <br/>Banco de Dados Docker funcionando.<br/><br/>FusionLabs Brasil Ltda." . PHP_EOL;

mysqli_close($link);
