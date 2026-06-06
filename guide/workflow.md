# No adoptes un framework de SDD. Hazte el tuyo.

Este documento es dos cosas: un **índice** de para qué sirve cada skill, y la **guía de cómo las encadeno yo** en el día a día. Si vienes a usarlo como referencia, empieza por el flujo (más abajo) y vuelve al índice cuando necesites el detalle de una skill concreta.

Referencia rápida de para qué sirve cada una:

## Productivity

- **grill-me**: te interroga a fondo sobre un plan, pregunta a pregunta.
- **handoff**: resume la conversación en un doc de traspaso para otra sesión/agente.

## Engineering

- **setup-matt-pocock-skills**: configura el repo (tracker, labels, domain docs). Correr primero.
- **grill-with-docs**: grill-me + actualiza `CONTEXT.md`/ADRs con el lenguaje del proyecto.
- **to-prd**: convierte el contexto actual en un PRD y lo publica al tracker.
- **to-issues**: parte un plan/PRD en issues por vertical slices y los publica.
- **prototype**: prototipo desechable (terminal para lógica/estado, o variaciones de UI).
- **tdd**: red-green-refactor para un cambio puntual y acotado, sin pasar por PRD ni issues.
- **diagnose**: bucle disciplinado para bugs difíciles: reproducir → minimizar → hipótesis → instrumentar → arreglar → test de regresión. La clave es construir un feedback loop rápido y determinista.
- **improve-codebase-architecture**: busca refactors para hacer módulos más profundos.
- **coding-standards**: el listón universal de qué es buen código (deep modules, testabilidad, tests de comportamiento), reconciliado con las reglas del repo. Beben de él `code`/`check`; también se invoca suelta.
- **zoom-out**: sube un nivel y te da un mapa de módulos y llamadores de una zona.

## Flujo HITL propio (`code → check → commit`)

Adaptación human-in-the-loop: un issue cada vez, manual, controlando los commits.

- **code**: implementa un issue end-to-end (RGR donde encaja) y para dejando el árbol sucio: sin commit, push, rama ni cierre de issue. (`/code #N`)
- **check**: en sesión fresca (anti-sesgo), revisa el `git diff HEAD` contra el issue: arregla bugs/edge-cases en sitio y escribe tests para romper, flaggea gaps de spec/scope al humano. Deja el árbol verde, no commitea. (`/check #N`)
- **commit**: parte el árbol sucio en commits atómicos conventional y commitea solo con un OK literal. (`/commit`)

---

# Mi flujo de trabajo con estas skills

> Esta es la parte que de verdad importa. El índice de arriba te dice *qué* hace cada skill; esto te cuenta *cómo* las encadeno en el día a día. Está escrito para mí como guía, pero también para que cualquier compañero pueda copiar el flujo.

## De dónde sale esto: principios, no la última moda

Antes de hablar de skills conviene decir de dónde viene todo esto, porque no nace de buscar productividad. Llevo años creyendo en unos valores de ingeniería que existen desde mucho **antes de la IA** (*clean code*, *extreme programming*, módulos profundos, tests que verifican comportamiento), y no estoy dispuesto a tirarlos por la borda porque haya llegado una herramienta nueva. Este flujo es, sobre todo, **mi vía para seguir haciendo ingeniería con principios** en un momento en el que la corriente empuja justo al revés.

Y empuja fuerte. Las redes están llenas de gente vendiendo humo: **vibe coding disfrazado de SDD**, procesos que parecen rigurosos pero que por dentro son "dale al botón y reza". Todos venden **orden**; casi nadie vende **entendimiento**. Es fácil sentirse desalineado, ver cómo se normaliza meter código que nadie ha decidido de verdad, y no saber por dónde tirar.

Por eso me enganché a las skills de Matt Pocock. Es el primer divulgador que he visto hacer **en serio** la propuesta de valor contraria: usar la IA para hacer mejor tu trabajo, no para que lo haga por ti. Creo que sus skills pegaron el *boom* que pegaron precisamente por eso: absorbieron a toda una comunidad de *software crafters* que estaba desorientada. Lo que cuento aquí es mi adaptación de ese trabajo a mi forma de trabajar.

## Por qué no uso un framework de spec-driven development

Antes que nada, por qué hago esto con skills mías y no adopto uno de los frameworks que están de moda (spec-kit, OpenSpec, BMAD, Kiro, Tessl, superpowers y compañía). Que conste que muchos están bien hechos: varios ponen el *human-in-the-loop* en el centro (Kiro, por ejemplo, no escribe una línea hasta que apruebas la spec) y casi todos son abiertos y personalizables. Mi reticencia no va por ahí; tengo tres cosas que comentar al respecto.

- **El alineamiento que producen es ceremonioso, y la ceremonia se vuelve teatro.** El checkpoint existe, sí: te generan una spec, un plan, una lista de tareas y te piden el OK. Pero una spec de 600 líneas que apruebas sin interiorizarla **no es alineamiento real**: es un sello de goma. Y cuando luego algo sale torcido, descubres que nunca llegaste a entender de verdad lo que se iba a construir. Es el patrón que más he visto frustrar a la gente, a mí incluido: horas de proceso y, al final, código que el propio flujo daba por "completo" y que no era lo que querías.
- **Donde son rígidos, duelen.** Algunos te empujan a un raíl tipo waterfall: en spec-kit, tocar la spec a mitad te obliga a regenerar plan y tareas en cascada, así que más te vale acertar a la primera. Y en el extremo, Tessl, el código pasa a ser **desechable y regenerable desde la spec**, con el no-determinismo que eso arrastra (generas dos veces desde la misma spec y sale distinto). El día a día no es así: según la tarea quieres hacer unas cosas u otras, no recorrer el flujo entero cada vez.
- **Un flujo que no es tuyo produce alineamiento de baja calidad.** No es que sean cajas negras impenetrables (casi ninguno lo es, puedes editar sus plantillas); es que un framework que no has construido tú no lo conoces a fondo, y por eso no lo doblas con soltura a la tarea que tienes delante. Esa fluidez de pensar *con* la herramienta solo la tienes cuando la herramienta es tuya.

¿Ves el hilo? Los tres se reducen a lo mismo: **lo que de verdad importa es la calidad del alineamiento previo, y estos frameworks optimizan la ceremonia, no el entendimiento.** Por eso defiendo lo contrario: **hazte tu propio flujo.** Uno que conozcas a fondo, **modular** en vez de un raíl cerrado (eliges qué piezas usar según la tarea), y que ponga al humano a alinearse de verdad antes de implementar, no a firmar un documento que no ha leído. El flujo es tuyo, no al revés.

## La tesis: el humano decide el diseño, la IA ejecuta los detalles

Y si no es un framework cerrado, ¿cómo reparto entonces el trabajo entre la IA y yo? Ahí entra la tesis de todo esto. Si no la entiendes, el resto parece una simple lista de comandos.

La IA es muy buena escribiendo los detalles de implementación de un módulo: el cuerpo de las funciones, el algoritmo concreto, el manejo de un edge case. Donde se equivoca, y donde se equivoca caro, es en las **decisiones de diseño y arquitectura**: qué módulos existen, qué responsabilidad tiene cada uno, qué interfaz exponen, cómo encajan entre sí.

Así que reparto la atención en consecuencia. Trato cada módulo como una **caja gris** (la idea de los *deep modules*): me importa mucho su interfaz y su responsabilidad, y me importa poco lo que pasa dentro mientras cumpla el contrato. El esfuerzo humano (el *human-in-the-loop*) lo gasto en las costuras entre cajas, no en el relleno de cada caja.

La idea de los módulos profundos no es mía ni nueva: viene de *A Philosophy of Software Design*, de John Ousterhout, una lectura muy recomendable. Pero la era de la IA la ha vuelto crucial: tú diseñas la interfaz simple y la IA rellena la profundidad. Y con tests se potencia todavía más. Un módulo profundo se prueba por su **comportamiento**, no por sus detalles: si le pides **TDD** a la IA, los tests blindan la interfaz y te dan confianza en lo que ha rellenado por dentro. Un mar de *shallow modules* hace justo lo contrario: acabas probando implementación.

Todo el flujo de abajo está montado con un único objetivo: **llegar a la implementación con un acuerdo cerrado sobre qué se va a construir.** Quiero pasar a escribir código sabiendo que la IA va a hacer exactamente lo que hemos pactado, sin sorpresas a mitad de camino y sin tener que iterar el código veinte veces.

## El alineamiento previo no es opcional (si te llevas una sola cosa, que sea esta)

Voy a decir lo que de verdad pienso, aunque suene fuerte. Conoces la escena: la IA termina la implementación, abres el diff a revisar… y no es para nada lo que tenías en la cabeza. Si como ingeniero no priorizas alinearte con la IA *antes* de implementar, hasta el punto de saber casi exactamente cómo va a lucir tu código antes de que se escriba, esa escena se repite, y a partir de ahí lo que he visto pasar, en mí y en gente cercana, es una de dos:

1. **Acabas metiendo mal código en tu codebase.** Compila, pasa la review por encima, y dentro de unos meses te duele, porque nadie decidió de verdad cómo debía ser; simplemente salió así.
2. **O acabas iterando ese código veinte, cincuenta, cien veces** hasta que por fin se parece a lo que querías desde el principio. El tiempo que crees ahorrarte saltándote el alineamiento lo pagas con creces peleándote después con el resultado.

No hay una tercera vía mágica. Por eso, para mí, **el alineamiento previo es lo más importante de todo el flujo**, y `grill-me` es la skill que lo encarna, la más potente de todas con diferencia. Si de estas skills te llevas una sola pieza suelta a tu propio flujo, que sea esa: siéntate a grillarte con la IA hasta que los dos entendáis exactamente lo mismo, *y entonces* implementa.

## El cimiento: `setup` (todas las demás beben de aquí)

Antes del recorrido hay un paso que se hace **una vez por repo** y del que dependen todas las demás skills: **`setup-matt-pocock-skills`**. Es donde decides dónde viven las cosas de tu proyecto: tus **documentos de contexto** (`CONTEXT.md`, ADRs), tus **PRDs** y tus **issues**.

Lo importante es que **no es un "elige entre a, b o c"**, sino un **proceso conversacional**: hablas con la IA sobre cómo quieres trabajar en *este* repo y juntos cerráis las decisiones. Eso es precisamente lo que hace que el resto de skills sean tan versátiles entre proyectos:

- En un **proyecto personal** puedes trabajar directamente contra **issues de GitHub** (`gh`).
- En el **repo del trabajo** puedes usar **archivos markdown ignorados por git** como tracker local.
- Y si tu sitio es otro (GitLab, Jira, Linear…), se lo describes en lenguaje natural y queda registrado igual.

Todo es posible porque el setup no impone un flujo: captura *el tuyo*.

**¿Y cómo se enteran las demás skills?** El setup escribe un bloque `## Agent skills` en tu `CLAUDE.md`/`AGENTS.md` (con punteros a unos archivos bajo `docs/agents/` que detallan tracker, labels y layout de docs). Como ese archivo se carga en el contexto de **cada** sesión, cuando luego lanzas `to-issues`, `to-prd`, `diagnose` o cualquier otra, **ya saben dónde vive todo sin que tú se lo digas**. Configuras una vez; el resto del flujo lo da por sabido.

## El recorrido (camino feliz)

### 1. Alinearme con la IA antes de tocar código (`grill-me`)

Casi siempre arranco con una sesión de grilling. Y ojo, no es ejecutar `/grill-me` y ya está: estas skills son tan modulares que mis ejecuciones se parecen más a una conversación normal (*"vamos a hacer una sesión de `/grill-me` para cerrar cómo vamos a estructurar este servicio"*) que a un comando seco.

El caso obvio es cuando llega una idea cruda y poco definida: el grilling me obliga a resolver cada rama del árbol de decisiones antes de comprometerme. Si además quiero que el acuerdo quede escrito en el lenguaje del proyecto, uso **`grill-with-docs`**, que de paso actualiza `CONTEXT.md` y los ADRs con las decisiones según se van cerrando.

Pero el caso menos obvio, y donde más valor le saco, es **cuando producto ya me ha refinado la tarea**. Aunque no haya ninguna duda a nivel de usuario sobre *qué* hay que hacer, igualmente hago una sesión de grilling para alinearme con la IA sobre el *cómo* de la implementación. No es para decidir el producto; es para llegar a `code` con la **confianza** de que la IA y yo entendemos lo mismo. Ese rato de grilling me ahorra después horas de iterar código que no era lo que yo tenía en la cabeza. Es, literalmente, el take de arriba en acción: el alineamiento previo es lo que me evita las dos salidas malas, mal código o iterar sin fin.

> **Recomendación: desactiva la `AskUserQuestion` tool.** Es la tool con la que Claude, en vez de preguntarte en texto abierto, te ofrece respuestas cerradas tipo A/B/C para que elijas. Yo la tengo apagada **en general** (no solo para grilling), y se hace añadiendo esto a tu `CLAUDE.md` (yo a nivel de usuario, en `~/.claude/CLAUDE.md`, para que aplique a todos los repos; también vale a nivel de proyecto si solo lo quieres ahí):
>
> ```md
> ## Restrictions
>
> Do NOT use the AskUserQuestion tool.
> ```
>
> Desactivarla **no te quita preguntas**: Claude las sigue haciendo (al planear, al grillarte), solo que en texto plano, y tú respondes en texto plano. Donde más se nota la mejora es en `grill-me` y `grill-with-docs`, por dos razones. La primera, mecánica: en un grilling casi nunca quieres elegir un A/B/C cerrado; quieres poder decir *"A pero…"*, mezclar trozos de varias opciones o matizar, y la respuesta cerrada empobrece justo eso. La segunda, más afilada: tú como humano tienes que poder **redirigir** la conversación, y ojo, si un grill-me se te va a 100 o 200 preguntas, normalmente no es fallo de la IA ni de la skill, sino que delata que estás dando malas respuestas.

### 2. Cuando dudo del diseño, lo toco antes de comprometerme (`prototype`)

Si en el grilling aparece una duda real sobre el modelo de datos, una máquina de estados o cómo debería sentirse una UI, no sigo adelante a ciegas: monto un **prototipo desechable**. *"Hagamos un `/prototype` rápido para ver si este modelo de estados aguanta los tres flujos."* Es una herramienta de pensamiento, no de entrega: el código se tira. Sirve para cerrar una decisión de diseño con algo tangible delante, que es justo donde quiero gastar el HITL.

### 3. Dejar el trabajo cerrado y troceado (`to-prd` → `to-issues`)

Con el acuerdo cerrado, lo materializo. **`to-prd`** convierte el contexto de la conversación en un PRD y lo publica al tracker. **`to-issues`** parte ese plan en issues, cada uno agarrable de forma independiente. A partir de aquí el "qué" ya está decidido y escrito; lo que queda es ejecutar.

El detalle que más me ha cambiado el flujo está aquí: `to-issues` instruye explícitamente a la IA para que trocee en **vertical slices** y no en horizontal. Esto es poco común (la IA, si no le dices lo contrario, **siempre** tiende a partir en capas horizontales: primero toda la base de datos, luego toda la API, luego toda la UI), y es justo lo que no quieres. Con slices verticales cada issue cruza todas las capas y deja **algo funcionando end-to-end**. El resultado: mis *feedback loops* mejoraron muchísimo, porque cada issue cerrado es una rebanada real y comprobable del producto, no media tubería que no se puede probar hasta que el resto exista.

> Nota sobre el punto de entrada: no siempre empiezo en el paso 1. A veces llego con el contexto o el PRD ya hechos y entro directo a `to-issues` o incluso al loop de implementación. El recorrido es el mapa completo, no un peaje obligatorio.

### 4. El loop HITL, un issue cada vez (`code → check → commit`)

Esta es la parte más propia y, a la vez, la más fácil de explicar. Es un loop deliberadamente manual, un issue cada vez, en el que yo controlo cada paso:

- **`code`** (*"/code #N"*): implementa el issue end-to-end y **para dejando el árbol sucio**: sin commit, sin push, sin rama, sin cerrar el issue. La IA rellena las cajas grises.
- **`check`** (*"/check #N"*): en **sesión fresca** (clave: anti-sesgo, no es la misma IA que escribió el código), revisa el `git diff HEAD` contra el issue. Y no se limita a "checkear": **actúa**, mejora el código activamente por su cuenta, arregla bugs y edge cases en el sitio y escribe tests para romper. Solo me sube a mí lo que no puede decidir sola: los gaps de spec o de scope, que me **flaggea** para que yo resuelva. Deja el árbol verde, pero no commitea.
- **`commit`** (*"/commit"*): parte el árbol sucio en commits atómicos *conventional* y solo commitea cuando le doy un OK literal.

El reparto del paso 1 vuelve a aparecer aquí: la IA hace el trabajo de relleno (`code`) y el de endurecer y corregir ese código (`check`), pero las decisiones que importan (aceptar un gap de scope, dar el OK a los commits) siguen siendo mías.

Un detalle que comparten ambas: ni `code` ni `check` inventan qué es "buen código". Beben de un listón común, **`coding-standards`**, que es lo que les dice qué listón aplicar al escribir y al revisar. Lo explico en detalle en la caja de herramientas, porque también se usa por su cuenta.

## Las maniobras: cuando algo se tuerce

El camino de arriba es el feliz, pero el día a día no es lineal. Cuando en pleno `code` o `check` me topo con un imprevisto, tengo dos maniobras según el tamaño del problema:

- **Volver atrás.** Si la duda toca el diseño, retrocedo a `grill-me` o `prototype` para recerrar la decisión antes de seguir. Mejor parar y realinear que arrastrar una arquitectura dudosa.
- **Encolar con `to-issues`.** Si lo que aparece es trabajo nuevo pero separable (un refactor que se ve venir, un bug colateral), no descarrilo el issue actual: creo un issue que entra en la cola y se aborda después.

## La caja de herramientas transversal

Estas skills no son un paso del recorrido sino compañeras de viaje que entran cuando hacen falta:

- **`handoff`**: la más polivalente de todas, y la que más se malinterpreta. **No es un `/compact`**: no va de "comprimir" una sesión para que ocupe menos. Va de **fabricar el contexto exacto que necesita otra sesión para hacer una cosa concreta**. Lo uso en las dos direcciones: un handoff *hacia adelante* para arrancar una sesión nueva con instrucciones y contexto específicos para una tarea acotada; y luego, desde esa segunda sesión, otro handoff *de vuelta* (solo con las conclusiones) hacia la sesión principal de la que venía, para retomarla sin arrastrar todo el ruido del trabajo intermedio. Con un poco de creatividad le sacas muchísimo: es un mecanismo para mover contexto entre sesiones a voluntad, no un botón de "resumir".
- **`zoom-out`**: mi botón de *"explícamelo como si tuviera cinco años"*. Cuando la IA me suelta algo que no conozco (un concepto, una librería, una parte del sistema), le pido un `zoom-out` para que suba de nivel y me lo explique en simple antes de seguir. Es para no asentir a ciegas.
- **`diagnose`**: mi loop completo para fixear un bug: reproducir → minimizar → hipótesis → instrumentar → arreglar → test de regresión. Cuando algo está roto, no improviso; arranco `diagnose` y dejo que el método haga el trabajo.
- **`tdd`**: la uso poco, y a propósito. En el recorrido normal el TDD ya vive dentro de `code` (tiene su propia mini-fase de red-green-refactor), así que no necesito la skill suelta. La saco solo para un **cambio puntual y muy acotado**: cuando quiero que la IA implemente algo pequeño respetando el ciclo TDD sin montar PRD, issues ni el resto del flujo. Es mi atajo para esos arreglos sueltos en los que el recorrido completo sobra pero el rigor de los tests no.
- **`improve-codebase-architecture`**: cuando quiero buscar oportunidades de hacer los módulos más profundos (coherente con la tesis de las cajas grises).
- **`coding-standards`**: mi listón universal de qué es buen código: módulos profundos (*deep modules*), diseño para la testabilidad, tests que verifican comportamiento por la interfaz pública, mocking solo en las fronteras del sistema y *clean code* sin pasarse de listo. Lo primero que hace es **reconciliar ese listón con las reglas del propio repo** (`CONTEXT.md`, `docs/adr/`, `CLAUDE.md`/`AGENTS.md`): en caso de conflicto, gana el repo. Es de la que beben `code` y `check` para saber qué listón aplicar, pero, fiel a la modularidad, también la invoco suelta, como una conversación normal: *"¿qué opinas de esto teniendo en cuenta los `/coding-standards`?"*. Comparte tesis con `improve-codebase-architecture`: las cajas grises profundas son, literalmente, parte del listón.

## En una frase

Gasto mi atención humana en cerrar las decisiones de diseño *antes* de implementar (grilling, prototipos, PRD/issues), trato cada módulo como una caja gris, y dejo que la IA ejecute los detalles dentro de un loop manual y controlado (`code → check → commit`) donde yo me reservo el OK final.

## Hazte el tuyo

Si te llevas algo de todo esto, que no sea la lista de comandos: que sea la idea de fondo. No adoptes un flujo cerrado que no has construido tú; **hazte el tuyo.** Más que un consejo práctico, es la forma que he encontrado de **proteger mi manera de cuidar lo que construyo** justo ahora que la corriente empuja a soltar eso.

---

## Créditos

La mayoría de las skills que aparecen en esta guía (`grill-me`, `grill-with-docs`, `handoff`, `setup-matt-pocock-skills`, `to-prd`, `to-issues`, `prototype`, `tdd`, `diagnose`, `improve-codebase-architecture`, `zoom-out`) **son de [Matt Pocock](https://github.com/mattpocock)** y viven en su repo: **[github.com/mattpocock/skills](https://github.com/mattpocock/skills)**. Se instalan con [skills.sh](https://skills.sh) (`npx skills add mattpocock/skills --skill …`). Todo el crédito de ese trabajo es suyo; yo soy un usuario que las adoptó.

Mi aporte propio es:

- **El flujo**: cómo encadeno estas piezas en el día a día (esta guía).
- **Mis 4 skills del loop HITL**: `code`, `check`, `commit` y `coding-standards`, una adaptación *human-in-the-loop* (un issue cada vez, controlando los commits) inspirada en el trabajo de Matt.
- **`check-upstream`**: una skill de proyecto que vigila el repo de Matt y mantiene mi manifiesto al día cuando sus skills evolucionan.

Gracias a Matt por estas skills y por ser de los pocos que defienden de verdad usar la IA sin bajar el listón. Buena parte de mi flujo no existiría sin su trabajo.
