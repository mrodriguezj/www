<?php
require_once __DIR__ . '/env_loader.php';

class Database {
    private $conn;

    public function getConnection() {
        if ($this->conn === null) {
            try {
                $dsn = "mysql:host=" . getenv('DB_HOST') . ";dbname=" . getenv('DB_NAME') . ";charset=utf8mb4";
                $this->conn = new PDO($dsn, getenv('DB_USER'), getenv('DB_PASS'), [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false
                ]);
            } catch (PDOException $exception) {
                die(json_encode(["error" => "Conexión fallida: " . $exception->getMessage()]));
            }
        }
        return $this->conn;
    }
}
?>
