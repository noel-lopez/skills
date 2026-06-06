# skills

> Cómo trabajo con IA sin renunciar al oficio: un flujo modular de *agent skills* donde **el humano decide el diseño y la IA ejecuta los detalles**.

La IA es muy buena escribiendo el relleno de un módulo —el cuerpo de las funciones, el algoritmo concreto, el manejo de un edge case—. Donde se equivoca, y se equivoca caro, es en las **decisiones de diseño**: qué módulos existen, qué responsabilidad tiene cada uno, qué interfaz exponen. Así que gasto mi atención humana en cerrar esas decisiones *antes* de implementar, trato cada módulo como una caja gris, y dejo que la IA rellene el interior dentro de un loop manual y controlado donde me reservo el OK final.

## 📊 Resumen visual del flujo

Un recorrido visual del flujo, de la tesis a las skills:

**→ [noel-lopez.github.io/skills](https://noel-lopez.github.io/skills/)**

## 📖 La guía completa

La narración en profundidad —por qué no uso un framework de SDD, el reparto humano/IA, el camino feliz y las válvulas de retorno— está en:

**→ [`guide/workflow.md`](guide/workflow.md)**

## Instalación

Las skills se instalan con [skills.sh](https://skills.sh). Dos conjuntos, dos comandos.

**Mis 4 skills** (el loop HITL `code → check → commit` + el listón `coding-standards`):

```bash
npx skills add noel-lopez/skills --skill code check commit coding-standards
```

**Las skills de Matt Pocock** que uso en el flujo (son suyas, viven en su repo — ver [créditos](#créditos)):

```bash
npx skills add mattpocock/skills --skill grill-me grill-with-docs setup-matt-pocock-skills to-prd to-issues prototype tdd diagnose improve-codebase-architecture zoom-out handoff
```

## Las skills de Matt Pocock

El flujo se apoya en estas 11 skills de [Matt Pocock](https://github.com/mattpocock). No las alojo aquí: se instalan desde su repo con el comando de arriba. Esta tabla es solo un índice de para qué uso cada una.

| Skill | Qué hace | Fuente |
|---|---|---|
| `grill-me` | Te interroga a fondo sobre un plan, pregunta a pregunta. | [SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md) |
| `handoff` | Resume la conversación en un doc de traspaso para otra sesión/agente. | [SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff/SKILL.md) |
| `setup-matt-pocock-skills` | Configura el repo (tracker, labels, domain docs). Correr primero. | [SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/SKILL.md) |
| `grill-with-docs` | `grill-me` + actualiza `CONTEXT.md`/ADRs con el lenguaje del proyecto. | [SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/SKILL.md) |
| `to-prd` | Convierte el contexto actual en un PRD y lo publica al tracker. | [SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/to-prd/SKILL.md) |
| `to-issues` | Parte un plan/PRD en issues por vertical slices y los publica. | [SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/to-issues/SKILL.md) |
| `prototype` | Prototipo desechable (terminal para lógica/estado, o variaciones de UI). | [SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/prototype/SKILL.md) |
| `tdd` | Red-green-refactor con slices verticales, un test a la vez. | [SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/tdd/SKILL.md) |
| `diagnose` | Bucle disciplinado para bugs difíciles: reproducir → minimizar → hipótesis → instrumentar → arreglar → test de regresión. | [SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/diagnose/SKILL.md) |
| `improve-codebase-architecture` | Busca refactors para hacer módulos más profundos. | [SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/improve-codebase-architecture/SKILL.md) |
| `zoom-out` | Sube un nivel y te da un mapa de módulos y llamadores de una zona. | [SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/zoom-out/SKILL.md) |

## `check-upstream`

Como las skills de Matt evolucionan, llevo una skill de proyecto, **`check-upstream`** (en [`.claude/skills/`](.claude/skills/check-upstream/)), que audita su repo y mantiene al día mi manifiesto ([`upstream/matt-skills.json`](upstream/matt-skills.json)). No es instalable por otros —es la mecánica con la que vigilo el drift contra el upstream— y por eso no aparece en los comandos de instalación.

## Desarrollar/iterar estas skills

Esto es la **mecánica de iteración** con la que mantengo mis 4 skills, no la vía de instalación (para usarlas, ve a [Instalación](#instalación)).

```bash
git clone https://github.com/noel-lopez/skills.git
cd skills
./scripts/link-skills.sh
```

`link-skills.sh` symlinkea cada skill de `skills/` a `~/.claude/skills/<nombre>`, así que las ediciones en el repo son **live**. El ciclo es: edito en el repo → el symlink lo refleja al instante → pruebo en una sesión real → abro PR. (`check-upstream` vive en `.claude/skills/` y queda fuera del link automáticamente, que es lo correcto.)

## Créditos

Las skills documentadas en la tabla de arriba son obra de **[Matt Pocock](https://github.com/mattpocock)** y viven en **[github.com/mattpocock/skills](https://github.com/mattpocock/skills)**; se instalan con **[skills.sh](https://skills.sh)**. Todo el crédito de ese trabajo es suyo.

Mi aporte es el **flujo** (cómo encadeno las piezas), mis **4 skills** del loop HITL (`code`, `check`, `commit`, `coding-standards`) y la skill **`check-upstream`**.

## Licencia

[MIT](LICENSE) © 2026 Noel López. Compatible con la licencia (también MIT) de las skills de Matt Pocock.
