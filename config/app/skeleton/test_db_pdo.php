<?php

$DBuser = 'root';
$DBpass = $_ENV['MYSQL_ROOT_PASSWORD'];
$pdo = null;

try{
    $database = 'mysql:host=database:3306';
    $pdo = new PDO($database, $DBuser, $DBpass);
    echo "Successo: A conexão com o Banco de Dados está funcionando! <br/>Banco de Dados Docker funcionando.<br/><br/>FusionLabs Brasil Ltda.";    
} catch(PDOException $e) {
    echo "Erro: Impossível conectar ao Banco de Dados MySql. Erro:\n $e";
}

$pdo = null;