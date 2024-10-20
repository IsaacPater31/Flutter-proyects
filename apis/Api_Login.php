<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *"); // Permite todas las solicitudes de cualquier dominio
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Métodos permitidos
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Permite el encabezado 'Content-Type' y 'Authorization'

// En caso de una solicitud OPTIONS (usada para verificar permisos CORS)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurar el tipo de contenido
header('Content-Type: application/json');

// Conexión a la base de datos
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "monitoreo_ruido";

$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Conexión fallida: " . $conn->connect_error]));
}

// Leer los datos de la solicitud JSON
$data = json_decode(file_get_contents("php://input"), true);

// Verificar que los campos estén presentes
if (isset($data['User'], $data['Password'])) {
    $user = $data['User'];
    $password = $data['Password'];

    // Buscar el usuario en la base de datos
    $sql = "SELECT Password FROM usuarios WHERE User = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $user);
    $stmt->execute();
    $stmt->bind_result($hashed_password);
    $stmt->fetch();

    // Verificar si el usuario existe y si la contraseña es correcta
    if ($hashed_password) {
        if (password_verify($password, $hashed_password)) {
            echo json_encode(["status" => 1, "message" => "Inicio de sesión exitoso"]); // Inicio de sesión exitoso
        } else {
            echo json_encode(["status" => 0, "message" => "Credenciales inválidas"]); // Credenciales inválidas
        }
    } else {
        echo json_encode(["status" => 0, "message" => "El usuario no existe"]); // Usuario no encontrado
    }

    $stmt->close();
} else {
    echo json_encode(["status" => "missing_fields", "message" => "Faltan campos en la solicitud"]); // Faltan campos
}

$conn->close();
?>
