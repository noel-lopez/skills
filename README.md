# skills

> Cómo uso la IA sin soltar el cuidado por el código que dejo detrás: un flujo modular de *agent skills* donde **el humano decide el diseño y la IA ejecuta los detalles**.

La IA escribe muy bien el relleno de un módulo, pero se equivoca en las decisiones de diseño, y se equivoca caro. Así que el diseño lo cierro yo antes de implementar, trato cada módulo como una caja gris y dejo que la IA rellene el interior dentro de un loop manual donde me reservo el OK final.

## Resumen visual del flujo

El flujo entero de un vistazo, de la tesis a las skills. Nació como una charla interna; ojalá acabe en un evento público.

**→ [noel-lopez.github.io/skills](https://noel-lopez.github.io/skills/)**

## La guía completa

El desarrollo entero está en [`guide/workflow.md`](guide/workflow.md): por qué no uso un framework de SDD, cómo reparto el trabajo con la IA, el camino feliz, las maniobras para cuando algo se tuerce, y el índice de para qué uso cada skill (las mías y las de Matt Pocock). Si prefieres verlo de un vistazo antes de leer, está el [recorrido visual](#resumen-visual-del-flujo).

## Instalación

Las skills se instalan con [skills.sh](https://skills.sh). Dos conjuntos, dos comandos.

**Mis 4 skills** (el loop HITL `code → check → commit` + el listón `coding-standards`):

```bash
npx skills add noel-lopez/skills --skill code check commit coding-standards
```

**Las skills de Matt Pocock** que uso en el flujo (son de Matt Pocock; ver [créditos](#créditos)):

```bash
npx skills add mattpocock/skills --skill grill-me grill-with-docs setup-matt-pocock-skills to-prd to-issues prototype tdd diagnose improve-codebase-architecture zoom-out handoff
```

## `check-upstream`

Como las skills de Matt van evolucionando, llevo una skill de proyecto, **`check-upstream`** (en [`.claude/skills/`](.claude/skills/check-upstream/)), que audita su repo y mantiene al día mi manifiesto ([`upstream/matt-skills.json`](upstream/matt-skills.json)). No es instalable por otros, sino la mecánica con la que vigilo si sus skills se han movido respecto a las que tengo registradas; por eso no aparece en los comandos de instalación.

## Créditos

Las skills de Matt Pocock que uso en el flujo son obra suya y viven en [github.com/mattpocock/skills](https://github.com/mattpocock/skills); se instalan con [skills.sh](https://skills.sh). Todo el crédito de ese trabajo es suyo. Mi aporte es el flujo (cómo encadeno las piezas), mis 4 skills del loop HITL (`code`, `check`, `commit`, `coding-standards`) y la skill `check-upstream`.

Gracias a Matt por estas skills y por ser de los pocos que defienden de verdad usar la IA sin bajar el listón. Buena parte de mi flujo no existiría sin su trabajo.

## Licencia

[MIT](LICENSE) © 2026 Noel López.
