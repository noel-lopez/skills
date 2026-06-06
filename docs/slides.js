/* ============================================================
   Navegación del deck
   - Teclado ← → · dots clicables · contador
   - Revelado por pasos dentro de un slide
   - Barra de progreso del borde (motivo del flujo, acto 4)
   - Sincronización con la vista de narrador (notes.html):
     window.open + postMessage, bidireccional. Tecla "P".
   ============================================================ */
(function () {
  "use strict";

  const slides = Array.from(document.querySelectorAll(".slide"));
  const dotsWrap = document.getElementById("dots");
  const counterCurrent = document.getElementById("counterCurrent");
  const counterTotal = document.getElementById("counterTotal");
  const prevBtn = document.getElementById("prevBtn");
  const nextBtn = document.getElementById("nextBtn");
  const flowbar = document.getElementById("flowbar");
  const flowSegs = flowbar ? Array.from(flowbar.children) : [];

  let current = 0; // índice de slide
  let step = 0; // paso de revelado dentro del slide
  let presenterWin = null; // ventana de narrador

  const stepsOf = (i) => parseInt(slides[i].dataset.steps, 10) || 0;

  // ---- Construir los dots de progreso ----
  slides.forEach((_, i) => {
    const dot = document.createElement("button");
    dot.className = "chrome__dot";
    dot.setAttribute("aria-label", "Ir al slide " + (i + 1));
    dot.addEventListener("click", () => goTo(i));
    dotsWrap.appendChild(dot);
  });
  const dots = Array.from(dotsWrap.children);
  counterTotal.textContent = String(slides.length);

  // ---- Revelado por pasos de un slide ----
  function applySteps(slide, s) {
    // Paso actual expuesto en el DOM: deja a CSS reaccionar a un paso EXACTO
    // (no solo "≥ k" como hace .is-revealed). Lo usa el popup del slide 18.
    slide.dataset.step = String(s);
    slide.querySelectorAll("[data-step]").forEach((el) => {
      const k = parseInt(el.dataset.step, 10) || 0;
      el.classList.toggle("is-revealed", s >= k);
    });

    // Diagrama del flujo: nodo activo = última etapa revelada
    slide.querySelectorAll(".flow__step").forEach((stage, i) => {
      stage.classList.toggle("is-shown", i < s);
      stage.classList.toggle("is-active", i === s - 1);
    });
    const active = s - 1;
    slide.querySelectorAll(".flow__panel").forEach((panel) => {
      const isIntro = panel.hasAttribute("data-intro");
      const stage = parseInt(panel.dataset.stage, 10);
      panel.classList.toggle("is-active", isIntro ? s === 0 : stage === active);
    });
  }

  // ---- Barra de progreso del borde (acto 4) ----
  function updateFlowbar(slide) {
    if (!flowbar) return;
    const data = slide.dataset.flow;
    if (!data) {
      flowbar.classList.remove("is-visible");
      flowSegs.forEach((s) => s.classList.remove("is-active", "is-past"));
      return;
    }
    const activeIdx = data.split(",").map((n) => parseInt(n, 10));
    const maxA = Math.max.apply(null, activeIdx);
    flowSegs.forEach((seg, i) => {
      const isActive = activeIdx.indexOf(i) !== -1;
      seg.classList.toggle("is-active", isActive);
      seg.classList.toggle("is-past", !isActive && i < maxA);
    });
    flowbar.classList.add("is-visible");
  }

  // ---- Persistencia del slide (sobrevive recargas en file://) ----
  // Vía localStorage, NO la URL: tocar el hash resetearía el zoom del navegador
  // (el zoom es por-URL). Formato guardado: "16.2" (slide.paso), 1-based.
  const STORE_KEY = "deck:sdd:pos";

  function readLocation() {
    let raw = null;
    try {
      raw = localStorage.getItem(STORE_KEY);
    } catch (e) {
      return; // localStorage no disponible: arrancamos en el slide 1
    }
    const m = /^(\d+)(?:\.(\d+))?$/.exec(raw || "");
    if (!m) return;
    const i = parseInt(m[1], 10) - 1;
    if (i < 0 || i >= slides.length) return;
    current = i;
    const s = parseInt(m[2], 10) || 0;
    step = Math.min(Math.max(s, 0), stepsOf(i));
  }

  function writeLocation() {
    try {
      localStorage.setItem(STORE_KEY, current + 1 + (step ? "." + step : ""));
    } catch (e) {
      /* sin persistencia si localStorage falla; no es crítico */
    }
  }

  // ---- Render ----
  function render() {
    writeLocation();
    slides.forEach((slide, i) => {
      const isActive = i === current;
      slide.classList.toggle("is-active", isActive);
      if (isActive) {
        applySteps(slide, step);
        updateFlowbar(slide);
      }
    });
    dots.forEach((dot, i) => dot.classList.toggle("is-active", i === current));
    counterCurrent.textContent = String(current + 1);
    syncPresenter();
  }

  // ---- Navegación ----
  function goTo(i) {
    if (i < 0 || i >= slides.length) return;
    current = i;
    step = 0;
    render();
  }

  function next() {
    if (step < stepsOf(current)) {
      step += 1;
      render();
    } else if (current < slides.length - 1) {
      goTo(current + 1);
    }
  }

  function prev() {
    if (step > 0) {
      step -= 1;
      render();
    } else if (current > 0) {
      current -= 1;
      step = stepsOf(current);
      render();
    }
  }

  // ---- Vista de narrador ----
  function openPresenter() {
    presenterWin = window.open(
      "notes.html",
      "presenter",
      "width=720,height=820"
    );
  }

  function syncPresenter() {
    if (presenterWin && !presenterWin.closed) {
      presenterWin.postMessage(
        { type: "sync", index: current, step: step, total: slides.length },
        "*"
      );
    }
  }

  window.addEventListener("message", (e) => {
    const msg = e.data || {};
    if (msg.type === "ready") {
      // La ventana de narrador acaba de cargar: empújale el estado actual.
      if (e.source) presenterWin = e.source;
      syncPresenter();
    } else if (msg.type === "nav") {
      if (msg.dir === "next") next();
      else if (msg.dir === "prev") prev();
    }
  });

  // ---- Cuadrícula de slides (overview · tecla "G") ----
  // Clona cada .slide a tamaño-ventana dentro de un wrapper escalado, para que
  // los vw/vh resuelvan igual que en la presentación real. Un solo marcador
  // índigo: empieza sobre la actual y se mueve con ←/→. Enter/clic navega.
  const gridOverlay = document.getElementById("gridOverlay");
  const gridEl = document.getElementById("grid");
  let gridOpen = false;
  let gridFocus = 0; // índice de la celda marcada

  // Step en el que se renderiza la miniatura: final por defecto; override
  // puntual con data-thumb-step (p.ej. "0" en slides cuyo paso final
  // levanta un popup que no queremos congelar en la miniatura).
  const thumbStepOf = (i) => {
    const slide = slides[i];
    const raw = slide.dataset.thumbStep;
    return raw != null ? parseInt(raw, 10) || 0 : stepsOf(i);
  };

  function buildGrid() {
    // Escala derivada de la ventana actual (puede haber cambiado de tamaño).
    const cellW = Math.max(200, Math.round(window.innerWidth * 0.18));
    const scale = cellW / window.innerWidth;
    gridEl.style.setProperty("--cell-w", cellW + "px");
    gridEl.style.setProperty("--cell-h", Math.round(window.innerHeight * scale) + "px");
    gridEl.style.setProperty("--thumb-scale", String(scale));

    gridEl.textContent = "";
    slides.forEach((slide, i) => {
      // <div>, no <button>: los botones imponen text-align:center (UA), que se
      // heredaría hacia el contenido clonado y descuadraría las alineaciones.
      const cell = document.createElement("div");
      cell.className = "grid__cell" + (i === current ? " is-current" : "");
      cell.setAttribute("role", "button");
      cell.setAttribute("aria-label", "Ir al slide " + (i + 1));

      const stage = document.createElement("div");
      stage.className = "grid__stage";
      const clone = slide.cloneNode(true);
      clone.classList.remove("is-active");
      applySteps(clone, thumbStepOf(i)); // estado fijado en clon desacoplado: sin transición al insertar
      stage.appendChild(clone);

      const num = document.createElement("span");
      num.className = "grid__num";
      num.textContent = String(i + 1);

      cell.appendChild(stage);
      cell.appendChild(num);
      cell.addEventListener("click", () => {
        goTo(i);
        closeGrid();
      });
      gridEl.appendChild(cell);
    });
  }

  function markFocus(i) {
    const cells = gridEl.children;
    if (cells[gridFocus]) cells[gridFocus].classList.remove("is-current");
    gridFocus = Math.min(Math.max(i, 0), cells.length - 1);
    const cell = cells[gridFocus];
    if (cell) {
      cell.classList.add("is-current");
      cell.scrollIntoView({ block: "nearest" });
    }
  }

  function openGrid() {
    buildGrid();
    gridOverlay.hidden = false;
    gridOpen = true;
    gridFocus = current;
  }

  function closeGrid() {
    gridOverlay.hidden = true;
    gridOpen = false;
    gridEl.textContent = ""; // suelta los clones
  }

  function toggleGrid() {
    if (gridOpen) closeGrid();
    else openGrid();
  }

  function handleGridKey(e) {
    switch (e.key) {
      case "ArrowLeft":
      case "ArrowUp":
      case "PageUp":
        e.preventDefault();
        markFocus(gridFocus - 1);
        break;
      case "ArrowRight":
      case "ArrowDown":
      case "PageDown":
        e.preventDefault();
        markFocus(gridFocus + 1);
        break;
      case "Home":
        e.preventDefault();
        markFocus(0);
        break;
      case "End":
        e.preventDefault();
        markFocus(slides.length - 1);
        break;
      case "Enter":
        e.preventDefault();
        goTo(gridFocus);
        closeGrid();
        break;
      case "Escape":
      case "g":
      case "G":
        e.preventDefault();
        closeGrid();
        break;
    }
  }

  // Clic en el backdrop (fuera de cualquier celda) cierra la modal.
  gridOverlay.addEventListener("click", (e) => {
    if (e.target === gridOverlay) closeGrid();
  });

  // ---- Eventos ----
  nextBtn.addEventListener("click", next);
  prevBtn.addEventListener("click", prev);

  document.addEventListener("keydown", (e) => {
    // Con la cuadrícula abierta, el teclado la controla a ella (el deck de
    // fondo no avanza); goTo solo se dispara con Enter/clic.
    if (gridOpen) {
      handleGridKey(e);
      return;
    }
    if (e.key === "g" || e.key === "G") {
      e.preventDefault();
      toggleGrid();
      return;
    }
    switch (e.key) {
      case "ArrowRight":
      case " ":
      case "PageDown":
        e.preventDefault();
        next();
        break;
      case "ArrowLeft":
      case "PageUp":
        e.preventDefault();
        prev();
        break;
      case "Home":
        e.preventDefault();
        goTo(0);
        break;
      case "End":
        e.preventDefault();
        goTo(slides.length - 1);
        break;
      case "p":
      case "P":
        e.preventDefault();
        openPresenter();
        break;
    }
  });

  readLocation();
  render();
})();
