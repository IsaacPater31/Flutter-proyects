<?php
// Iniciar sesión
session_start();

// Conexión a la base de datos
$host = "localhost";
$dbname = "monitoreo_ruido";
$username = "root";
$password = "";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(["message" => "Error de conexión: " . $e->getMessage()]);
    exit();
}

// Verificar si el usuario está logueado
if (isset($_SESSION['Usuario_ID'])) {
    $usuario_id = $_SESSION['Usuario_ID'];

    // Verificar que la petición sea POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Leer el cuerpo de la solicitud en formato JSON
        $data = json_decode(file_get_contents("php://input"), true);

        // Validar que los datos necesarios estén presentes
        if (isset($data['Nivel_Ruido'], $data['Decibelios'], $data['Direccion_Reporte'])) {
            $nivel_ruido = $data['Nivel_Ruido'];
            $decibelios = $data['Decibelios'];
            $direccion_reporte = $data['Direccion_Reporte'];
            $fecha = date('Y-m-d');
            $hora = date('H:i:s');

            // Preparar la consulta SQL para insertar los datos
            $sql = "INSERT INTO ruido (Usuario_ID, Nivel_Ruido, Decibelios, Fecha, Hora, Direccion_Reporte)
                    VALUES (:usuario_id, :nivel_ruido, :decibelios, :fecha, :hora, :direccion_reporte)";

            $stmt = $pdo->prepare($sql);
            $stmt->bindParam(':usuario_id', $usuario_id);
            $stmt->bindParam(':nivel_ruido', $nivel_ruido);
            $stmt->bindParam(':decibelios', $decibelios);
            $stmt->bindParam(':fecha', $fecha);
            $stmt->bindParam(':hora', $hora);
            $stmt->bindParam(':direccion_reporte', $direccion_reporte);

            if ($stmt->execute()) {
                echo json_encode(["message" => "Registro guardado exitosamente."]);
            } else {
                echo json_encode(["message" => "Error al guardar el registro."]);
            }
        } else {
            echo json_encode(["message" => "Datos incompletos."]);
        }
    } else {
        echo json_encode(["message" => "Método no permitido."]);
    }
} else {
    echo json_encode(["message" => "Usuario no logueado."]);
}
?>
