function mostrarLoader() {
  document.getElementById("loader").classList.remove("hidden");
}

function ocultarLoader() {
  document.getElementById("loader").classList.add("hidden");
}

async function cargarTotalPagado() {
  try {
    const res = await fetch("http://localhost/api/index.php?endpoint=totalPagado");
    const data = await res.json();

    document.getElementById("totalPagado").textContent = `$${parseFloat(data.total_pagado).toLocaleString()}`;

    calcularRecuperacion();
  } catch (error) {
    console.error("Error al cargar total pagado:", error);
  }
}

async function cargarCarteraVencida() {
  try {
    const res = await fetch("http://localhost/api/index.php?endpoint=carteraVencida");
    const data = await res.json();

    document.getElementById("carteraVencida").textContent = `$${parseFloat(data.cartera_vencida).toLocaleString()}`;

    calcularRecuperacion();
  } catch (error) {
    console.error("Error al cargar cartera vencida:", error);
  }
}

async function cargarMorosos() {
  try {
    const res = await fetch("http://localhost/api/index.php?endpoint=morosos");
    const data = await res.json();

    renderTablaMorosos(data.morosos);
  } catch (error) {
    console.error("Error al cargar morosos:", error);
  }
}

function calcularRecuperacion() {
  const totalPagado = parseFloat(document.getElementById("totalPagado").textContent.replace(/[^\d.-]/g, '')) || 0;
  const carteraVencida = parseFloat(document.getElementById("carteraVencida").textContent.replace(/[^\d.-]/g, '')) || 0;

  if (totalPagado === 0 && carteraVencida === 0) {
    document.getElementById("porcentajeRecuperacion").textContent = "0%";
    return;
  }

  const porcentaje = (totalPagado / (totalPagado + carteraVencida)) * 100;
  document.getElementById("porcentajeRecuperacion").textContent = `${porcentaje.toFixed(2)}%`;
}

function renderTablaMorosos(morosos) {
  const tbody = document.querySelector("#tablaMorosos tbody");
  tbody.innerHTML = "";

  morosos.forEach(m => {
    const row = document.createElement("tr");
    row.classList.add("border-b", "hover:bg-gray-50");

    row.innerHTML = `
      <td>${m.nombre_cliente}</td>
      <td>${m.id_lote}</td>
      <td>${m.numero_pago}</td>
      <td>${m.fecha_vencimiento}</td>
      <td>$${parseFloat(m.monto_restante).toLocaleString()}</td>
      <td>${m.dias_mora} días</td>
      <td>${m.estatus_pago}</td>
    `;
    tbody.appendChild(row);
  });
}

document.addEventListener("DOMContentLoaded", async () => {
  mostrarLoader();

  await Promise.all([
    cargarTotalPagado(),
    cargarCarteraVencida(),
    cargarMorosos()
  ]);

  ocultarLoader();
});
