// Variables globales
let clientes = [];
let lotes = [];

// Cargar datos iniciales
window.addEventListener('DOMContentLoaded', () => {
    cargarClientes();
    cargarLotes();
});

// Cargar clientes desde API
function cargarClientes() {
    fetch("http://localhost/api/index.php?endpoint=clientes_listado")
        .then(response => response.json())
        .then(data => {
            clientes = data;
        })
        .catch(error => console.error("Error cargando clientes:", error));
}

// Cargar lotes disponibles desde API
function cargarLotes() {
    fetch("http://localhost/api/index.php?endpoint=lotes_disponibles")
        .then(response => response.json())
        .then(data => {
            lotes = data;
            console.log("Lotes disponibles:", lotes);
        })
        .catch(error => console.error("Error cargando lotes:", error));
}

// Autocomplete para clientes
const buscarClienteInput = document.getElementById("buscar_cliente");
const idClienteHidden = document.getElementById("id_cliente");

buscarClienteInput.addEventListener("input", () => {
    const valor = buscarClienteInput.value.toLowerCase();
    const sugerencias = clientes.filter(cliente => 
        cliente.nombre_completo.toLowerCase().includes(valor)
    );
    mostrarSugerencias(sugerencias, buscarClienteInput, idClienteHidden);
});

// Autocomplete para lotes
const buscarLoteInput = document.getElementById("buscar_lote");
const idLoteHidden = document.getElementById("id_lote");
const precioLoteInput = document.getElementById("precio_lote");
const precioListaInput = document.getElementById("precio_lista");

buscarLoteInput.addEventListener("input", () => {
    const valor = buscarLoteInput.value.toLowerCase();
    const sugerencias = lotes.filter(lote => 
        lote.descripcion.toLowerCase().includes(valor)
    );
    mostrarSugerenciasLotes(sugerencias);
});

function mostrarSugerencias(sugerencias, inputElement, hiddenElement) {
    let dropdown = document.getElementById("sugerencias_" + inputElement.id);

    if (!dropdown) {
        dropdown = document.createElement("ul");
        dropdown.id = "sugerencias_" + inputElement.id;
        dropdown.className = "absolute bg-white border rounded-md mt-1 w-full max-h-40 overflow-y-auto z-10 shadow-lg";
        dropdown.style.width = inputElement.offsetWidth + "px";
        dropdown.style.position = "absolute";
        inputElement.parentNode.appendChild(dropdown);
    }

    dropdown.innerHTML = "";

    sugerencias.forEach(item => {
        const li = document.createElement("li");
        li.className = "px-4 py-2 cursor-pointer hover:bg-indigo-100";
        li.textContent = item.nombre_completo;

        li.addEventListener("click", () => {
            inputElement.value = item.nombre_completo;
            hiddenElement.value = item.id_cliente;

            dropdown.innerHTML = "";
        });

        dropdown.appendChild(li);
    });
}

function mostrarSugerenciasLotes(sugerencias) {
    let dropdown = document.getElementById("sugerencias_lotes");

    if (!dropdown) {
        dropdown = document.createElement("ul");
        dropdown.id = "sugerencias_lotes";
        dropdown.className = "absolute bg-white border rounded mt-1 max-h-40 overflow-y-auto shadow-lg z-10";

        // Asignamos el ancho igual al input de búsqueda
        dropdown.style.width = buscarLoteInput.offsetWidth + "px";

        buscarLoteInput.parentNode.appendChild(dropdown);
    }

    dropdown.innerHTML = "";

    sugerencias.forEach(lote => {
        const li = document.createElement("li");
        li.className = "px-4 py-2 cursor-pointer hover:bg-indigo-100 truncate";
        li.textContent = lote.descripcion;

        li.addEventListener("click", () => {
            buscarLoteInput.value = lote.descripcion;
            idLoteHidden.value = lote.id_lote;

            precioLoteInput.value = lote.precio.toFixed(2);
            precioListaInput.value = lote.precio.toFixed(2);

            calcularPrecioVenta();
            dropdown.innerHTML = "";
        });

        dropdown.appendChild(li);
    });

    if (sugerencias.length === 0) {
        const noResult = document.createElement("li");
        noResult.className = "px-4 py-2 text-gray-500 truncate";
        noResult.textContent = "No encontrado";
        dropdown.appendChild(noResult);
    }
}

// Cálculo de precio de venta y saldo restante
const descuentoInput = document.getElementById("descuento");
const precioVentaInput = document.getElementById("precio_venta");
const montoEngancheInput = document.getElementById("monto_enganche");
const saldoRestanteInput = document.getElementById("saldo_restante");

precioListaInput.addEventListener("input", calcularPrecioVenta);
descuentoInput.addEventListener("input", calcularPrecioVenta);
montoEngancheInput.addEventListener("input", calcularSaldoRestante);

function calcularPrecioVenta() {
    const precioLista = parseFloat(precioListaInput.value) || 0;
    const descuento = parseFloat(descuentoInput.value) || 0;
    const precioVenta = precioLista - descuento;

    precioVentaInput.value = precioVenta.toFixed(2);

    calcularSaldoRestante();
}

function calcularSaldoRestante() {
    const precioVenta = parseFloat(precioVentaInput.value) || 0;
    const enganche = parseFloat(montoEngancheInput.value) || 0;
    const saldoRestante = precioVenta - enganche;

    saldoRestanteInput.value = saldoRestante.toFixed(2);
}

// Mostrar/ocultar campos de financiamiento
const formaPagoSelect = document.getElementById("forma_de_pago");
const financiamientoFields = document.getElementById("financiamientoFields");

formaPagoSelect.addEventListener("change", function() {
    if (this.value === "Financiamiento") {
        financiamientoFields.classList.remove("hidden");
    } else {
        financiamientoFields.classList.add("hidden");
    }
});

// Enviar el formulario al backend
document.getElementById("ventaForm").addEventListener("submit", function(event) {
    event.preventDefault();

    const formData = {
        id_cliente: parseInt(idClienteHidden.value),
        id_lote: parseInt(idLoteHidden.value),
        fecha_venta: document.getElementById("fecha_venta").value,
        precio_lote: parseFloat(precioLoteInput.value),
        precio_lista: parseFloat(precioListaInput.value),
        descuento: parseFloat(descuentoInput.value),
        autoriza_descuento: document.getElementById("autoriza_descuento").value,
        precio_venta: parseFloat(precioVentaInput.value),
        monto_enganche: parseFloat(montoEngancheInput.value),
        fecha_pago_enganche: document.getElementById("fecha_pago_enganche").value,
        saldo_restante: parseFloat(saldoRestanteInput.value),
        forma_de_pago: formaPagoSelect.value,
        plazo_meses: parseInt(document.getElementById("plazo_meses").value || 0),
        mensualidades: parseFloat(document.getElementById("mensualidades").value || 0),
        fecha_inicio_pago: document.getElementById("fecha_inicio_pago").value,
        observaciones: document.getElementById("observaciones").value
    };

    fetch("http://localhost/api/index.php?endpoint=registrar_venta_y_generar_calendario", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData)
    })
    .then(res => res.json())
    .then(data => {
        const responseMessage = document.getElementById("responseMessage");

        if (data.error) {
            responseMessage.style.color = "red";
            responseMessage.textContent = "❌ " + data.error;
        } else {
            responseMessage.style.color = "green";
            responseMessage.textContent = "✅ Venta registrada correctamente.";
            document.getElementById("ventaForm").reset();
            financiamientoFields.classList.add("hidden");
        }
    })
    .catch(error => {
        console.error("Error:", error);
        const responseMessage = document.getElementById("responseMessage");
        responseMessage.style.color = "red";
        responseMessage.textContent = "❌ Error en la solicitud.";
    });
});
