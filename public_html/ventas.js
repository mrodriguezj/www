// Variables globales
let clientes = [];
let lotes = [];

// Al cargar la página
window.addEventListener('DOMContentLoaded', () => {
    cargarClientes();
    cargarLotes();
    inicializarInputsMoney();
});

// 1️⃣ Cargar clientes desde el endpoint
function cargarClientes() {
    fetch("http://localhost/api/index.php?endpoint=clientes_listado")
        .then(response => response.json())
        .then(data => {
            clientes = data;
        })
        .catch(error => console.error("Error al cargar clientes:", error));
}

// 2️⃣ Cargar lotes disponibles desde el endpoint
function cargarLotes() {
    fetch("http://localhost/api/index.php?endpoint=lotes_disponibles")
        .then(response => response.json())
        .then(data => {
            lotes = data;
            console.log("Lotes cargados:", lotes); // Debug opcional
        })
        .catch(error => console.error("Error al cargar lotes:", error));
}

// 3️⃣ Autocomplete - Clientes
const buscarClienteInput = document.getElementById("buscar_cliente");
const idClienteHidden = document.getElementById("id_cliente");

buscarClienteInput.addEventListener("input", function() {
    const value = this.value.toLowerCase();
    const sugerencias = clientes.filter(cliente => 
        cliente.nombre_completo.toLowerCase().includes(value)
    );
    mostrarSugerencias(sugerencias, buscarClienteInput, idClienteHidden);
});

// 4️⃣ Autocomplete - Lotes
const buscarLoteInput = document.getElementById("buscar_lote");
const idLoteHidden = document.getElementById("id_lote");
const precioLoteInput = document.getElementById("precio_lote");

buscarLoteInput.addEventListener("input", function() {
    const value = this.value.toLowerCase();
    const sugerencias = lotes.filter(lote => 
        lote.descripcion.toLowerCase().includes(value)
    );
    mostrarSugerencias(sugerencias, buscarLoteInput, idLoteHidden, precioLoteInput);
});

// 5️⃣ Mostrar sugerencias para clientes y lotes
function mostrarSugerencias(sugerencias, inputElement, hiddenElement, extraField = null) {
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
        li.textContent = item.nombre_completo || item.descripcion;

        li.addEventListener("click", () => {
            inputElement.value = item.nombre_completo || item.descripcion;
            hiddenElement.value = item.id_cliente || item.id_lote;

            // Corrección clave: Asignamos el número crudo al campo
            if (extraField && (item.precio !== undefined || item.precio_lote !== undefined)) {
                const lotePrecio = item.precio !== undefined ? item.precio : item.precio_lote;

                extraField.value = lotePrecio.toFixed(2);
                document.getElementById("precio_lista").value = lotePrecio.toFixed(2);

                calcularPrecioVenta();
                inicializarInputsMoney(); // Refresca el formato después de la selección
            }

            dropdown.innerHTML = "";
        });

        dropdown.appendChild(li);
    });

    if (sugerencias.length === 0) {
        const noResult = document.createElement("li");
        noResult.className = "px-4 py-2 text-gray-500";
        noResult.textContent = "No encontrado";
        dropdown.appendChild(noResult);
    }
}

// 6️⃣ Inicializar los inputs de dinero con formato
function inicializarInputsMoney() {
    const moneyInputs = [
        "precio_lote", "precio_lista", "descuento",
        "precio_venta", "monto_enganche", "saldo_restante", "mensualidades"
    ];

    moneyInputs.forEach(id => {
        const input = document.getElementById(id);

        input.addEventListener("blur", () => {
            const value = parseFloat(input.value.replace(/,/g, "")) || 0;
            input.value = formatMoney(value);
        });

        input.addEventListener("focus", () => {
            const numericValue = input.value.replace(/,/g, "");
            input.value = numericValue;
        });
    });
}

// 7️⃣ Función que formatea el número a formato moneda
function formatMoney(amount) {
    return amount.toLocaleString('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
}

// 8️⃣ Cálculo de precio de venta y saldo restante
const precioListaInput = document.getElementById("precio_lista");
const descuentoInput = document.getElementById("descuento");
const precioVentaInput = document.getElementById("precio_venta");
const montoEngancheInput = document.getElementById("monto_enganche");
const saldoRestanteInput = document.getElementById("saldo_restante");

precioListaInput.addEventListener("input", calcularPrecioVenta);
descuentoInput.addEventListener("input", calcularPrecioVenta);
montoEngancheInput.addEventListener("input", calcularSaldoRestante);

function calcularPrecioVenta() {
    const precioLista = parseFloat(precioListaInput.value.replace(/,/g, "")) || 0;
    const descuento = parseFloat(descuentoInput.value.replace(/,/g, "")) || 0;
    const precioVenta = precioLista - descuento;

    precioVentaInput.value = formatMoney(precioVenta);

    calcularSaldoRestante();
}

function calcularSaldoRestante() {
    const precioVenta = parseFloat(precioVentaInput.value.replace(/,/g, "")) || 0;
    const enganche = parseFloat(montoEngancheInput.value.replace(/,/g, "")) || 0;
    const saldoRestante = precioVenta - enganche;

    saldoRestanteInput.value = formatMoney(saldoRestante);
}

// 9️⃣ Mostrar/ocultar campos de financiamiento
const formaPagoSelect = document.getElementById("forma_de_pago");
const financiamientoFields = document.getElementById("financiamientoFields");

formaPagoSelect.addEventListener("change", function() {
    if (this.value === "Financiamiento") {
        financiamientoFields.classList.remove("hidden");
    } else {
        financiamientoFields.classList.add("hidden");
    }
});

// 🔟 Enviar el formulario de venta al backend
document.getElementById("ventaForm").addEventListener("submit", function(event) {
    event.preventDefault();

    const formData = {
        id_cliente: parseInt(idClienteHidden.value),
        id_lote: parseInt(idLoteHidden.value),
        precio_lote: parseFloat(precioLoteInput.value.replace(/,/g, "")),
        precio_lista: parseFloat(precioListaInput.value.replace(/,/g, "")),
        descuento: parseFloat(descuentoInput.value.replace(/,/g, "")),
        autoriza_descuento: document.getElementById("autoriza_descuento").value,
        precio_venta: parseFloat(precioVentaInput.value.replace(/,/g, "")),
        monto_enganche: parseFloat(montoEngancheInput.value.replace(/,/g, "")),
        fecha_pago_enganche: document.getElementById("fecha_pago_enganche").value,
        saldo_restante: parseFloat(saldoRestanteInput.value.replace(/,/g, "")),
        forma_de_pago: formaPagoSelect.value,
        plazo_meses: parseInt(document.getElementById("plazo_meses").value || 0),
        mensualidades: parseFloat(document.getElementById("mensualidades").value.replace(/,/g, "")) || 0,
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
