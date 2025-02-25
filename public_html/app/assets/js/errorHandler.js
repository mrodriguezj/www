// Captura de errores JS
// Configuración
const API_URL = '/api/errores/log_js_error.php';
const MODO_DESARROLLO = true; // Cambia a false en producción

// Función para enviar errores al servidor
function enviarError(mensaje, archivo, linea, columna, stack) {
  fetch(API_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      mensaje,
      archivo,
      linea,
      columna,
      stack,
      navegador: navigator.userAgent,
      url: window.location.href,
      fecha: new Date().toISOString(),
    }),
  }).catch(() => console.error('No se pudo registrar el error en el servidor.'));
}

// Función para mostrar notificación visual
function mostrarNotificacionError(mensaje, archivo, linea, columna) {
  if (!MODO_DESARROLLO) return; // No mostrar en producción

  const notificacion = document.createElement('div');
  notificacion.className = 'error-notificacion';
  notificacion.innerHTML = `
    <strong>Error capturado:</strong> ${mensaje}<br>
    <small>${archivo ? `Archivo: ${archivo}` : ''} ${linea ? `| Línea: ${linea}` : ''} ${columna ? `| Columna: ${columna}` : ''}</small>
    <button class="cerrar-btn">&times;</button>
  `;

  document.body.appendChild(notificacion);

  // Cerrar notificación al hacer clic en el botón
  notificacion.querySelector('.cerrar-btn').onclick = () => notificacion.remove();

  // Desaparece automáticamente después de 10 segundos
  setTimeout(() => notificacion.remove(), 10000);
}

// Captura errores globales
window.onerror = function(mensaje, archivo, linea, columna, error) {
  enviarError(mensaje, archivo, linea, columna, error?.stack);
  mostrarNotificacionError(mensaje, archivo, linea, columna);
};

// Captura errores en promesas no manejadas
window.addEventListener('unhandledrejection', function(event) {
  enviarError(event.reason?.message || 'Error en promesa no manejada', '', '', '', event.reason?.stack);
  mostrarNotificacionError(event.reason?.message || 'Error en promesa', '', '', '');
});

// Estilos para las notificaciones
const estilos = document.createElement('style');
estilos.innerHTML = `
.error-notificacion {
  position: fixed;
  bottom: 20px;
  right: 20px;
  background-color: rgba(220, 38, 38, 0.9);
  color: white;
  padding: 16px;
  border-radius: 8px;
  font-family: Arial, sans-serif;
  max-width: 300px;
  z-index: 9999;
  box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}
.error-notificacion strong {
  font-size: 14px;
}
.error-notificacion small {
  display: block;
  font-size: 12px;
  margin-top: 4px;
}
.cerrar-btn {
  background: none;
  border: none;
  color: white;
  font-size: 16px;
  position: absolute;
  top: 4px;
  right: 8px;
  cursor: pointer;
}
`;
document.head.appendChild(estilos);
