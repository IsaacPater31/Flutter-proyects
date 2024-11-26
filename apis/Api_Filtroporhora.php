<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

header('Content-Type: application/json');

// Conexión a la base de datos
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "monitoreo_ruido";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Conexión fallida: " . $conn->connect_error]));
}

// Verificar que se reciba la hora
if (!isset($_GET['hora'])) {
    die(json_encode(["status" => "error", "message" => "No se proporcionó la hora."]));
}

$hora = (int)$conn->real_escape_string($_GET['hora']);

// Consulta para filtrar registros por una hora específica (todas las fechas)
$sql = "SELECT 
            AVG(Nivel_Ruido) AS Promedio, 
            MIN(Nivel_Ruido) AS Minimo, 
            MAX(Nivel_Ruido) AS Pico 
        FROM ruido 
        WHERE HOUR(Hora) = $hora";

$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $data = $result->fetch_assoc();
    echo json_encode(["status" => 1, "data" => $data]);
} else {
    echo json_encode(["status" => 0, "message" => "No se encontraron registros para la hora proporcionada."]);
}

$conn->close();
?>
