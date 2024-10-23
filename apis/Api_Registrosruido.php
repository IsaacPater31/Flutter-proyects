<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Manejo de solicitudes OPTIONS
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurar el tipo de contenido
header('Content-Type: application/json');

// Conexión a la base de datos
$servername = "localhost";
$username = "root"; // Cambia por tu usuario de la base de datos
$password = ""; // Cambia por tu contraseña de la base de datos
$dbname = "monitoreo_ruido";

$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Conexión fallida: " . $conn->connect_error]));
}

// Consulta para obtener los registros de ruido bajo
$sql = "SELECT Id_Medida, Nivel_Ruido, Fecha_Hora, Direccion_Reporte, Latitud, Longitud, Usuario_ID FROM ruido WHERE Nivel_Ruido < 31";
$result = $conn->query($sql);

// Comprobar errores en la consulta
if (!$result) {
    die(json_encode(["status" => "error", "message" => "Error en la consulta: " . $conn->error]));
}

$ruido_data = array();

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Convertir valores a float para asegurarte de que se devuelvan como números
        $ruido_data[] = [
            'Id_Medida' => $row['Id_Medida'],
            'Nivel_Ruido' => (float)$row['Nivel_Ruido'], // Asegurarse de que sea float
            'Fecha_Hora' => $row['Fecha_Hora'],
            'Direccion_Reporte' => $row['Direccion_Reporte'],
            'Latitud' => (float)$row['Latitud'], // Asegurarse de que sea float
            'Longitud' => (float)$row['Longitud'], // Asegurarse de que sea float
            'Usuario_ID' => $row['Usuario_ID']
        ];
    }
    echo json_encode(["status" => 1, "data" => $ruido_data]);
} else {
    echo json_encode(["status" => 0, "message" => "No se encontraron registros de ruido"]);
}

// Cerrar conexión
$conn->close();
?>