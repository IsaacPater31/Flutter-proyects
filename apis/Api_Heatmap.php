<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

header('Content-Type: application/json');

// Configuración de conexión a la base de datos
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "monitoreo_ruido";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Conexión fallida: " . $conn->connect_error]));
}

// Obtener los datos JSON del cuerpo de la solicitud
$data = json_decode(file_get_contents("php://input"), true);

// Validar que la fecha esté presente
if (!isset($data['fecha'])) {
    die(json_encode(["status" => 0, "message" => "La fecha es obligatoria."]));
}

$fecha = $conn->real_escape_string($data['fecha']);
$hora = isset($data['hora']) ? $conn->real_escape_string($data['hora']) : null;

// Construir la consulta SQL según los parámetros
if ($hora) {
    // Consulta para un día y una hora específica
    $sql = "
        SELECT lat, lng, AVG(Nivel_Ruido) AS nivelRuido
        FROM ruido
        WHERE Fecha = '$fecha' AND HOUR(Hora) = '$hora'
        GROUP BY lat, lng";
} else {
    // Consulta para todo el día
    $sql = "
        SELECT lat, lng, AVG(Nivel_Ruido) AS nivelRuido
        FROM ruido
        WHERE Fecha = '$fecha'
        GROUP BY lat, lng";
}

$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = [
            "lat" => (float)$row['lat'],
            "lng" => (float)$row['lng'],
            "nivelRuido" => round((float)$row['nivelRuido'], 2)
        ];
    }

    echo json_encode(["status" => 1, "data" => $data]);
} else {
    echo json_encode(["status" => 0, "message" => "No se encontraron datos para los criterios especificados."]);
}

$conn->close();
?>
