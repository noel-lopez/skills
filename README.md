# skills

> Cómo uso la IA sin soltar el cuidado por el código que dejo detrás: un flujo modular de *agent skills* donde **el humano decide el diseño y la IA ejecuta los detalles**.

La IA escribe muy bien el relleno de un módulo, pero se equivoca en las decisiones de diseño, y se equivoca caro. Así que el diseño lo cierro yo antes de implementar, trato cada módulo como una caja gris y dejo que la IA rellene el interior dentro de un loop manual donde me reservo el OK final.

## Resumen visual del flujo

El flujo entero de un vistazo, de la tesis a las skills. Nació como una charla interna; ojalá acabe en un evento público.

**→ [noel-lopez.github.io/skills](https://noel-lopez.github.io/skills/)**

## La guía completa

El desarrollo entero está en [`guide/workflow.md`](guide/workflow.md): por qué no uso un framework de SDD, cómo reparto el trabajo con la IA, el camino feliz y las maniobras para cuando algo se tuerce.

## Instalación

Las skills se instalan con [skills.sh](https://skills.sh). Dos conjuntos, dos comandos.

**Mis 4 skills** (el loop HITL `build → improve → commit` + el listón `coding-standards`), más `zoom-out`, que adopté de Matt cuando la retiró de su upstream (ver [créditos](#créditos)):

```bash
npx skills add noel-lopez/skills --skill build improve commit coding-standards zoom-out
```

**Las skills de Matt Pocock** que uso en el flujo (son de Matt Pocock; ver [créditos](#créditos)):

```bash
npx skills add mattpocock/skills --skill grill-me grilling grill-with-docs domain-modeling setup-matt-pocock-skills to-prd to-issues prototype tdd codebase-design diagnosing-bugs improve-codebase-architecture handoff
```

### Parche de invocación

Matt marca casi todas sus skills con `disable-model-invocation: true`, lo que obliga a que el nombre de la skill sea lo primero del prompt: ni a mitad de mensaje, ni encadenadas, ni referenciadas desde un handoff. Como yo las uso de forma conversacional, reaplico mi único delta de preferencia con un script que voltea ese flag de `true` a `false` en las tres que invoco así (`grill-with-docs`, `prototype`, `handoff`), sin forkear ni tocar el cuerpo. Es idempotente: instala primero, parchea después.

`grill-me` se queda fuera del parche a propósito: su cuerpo es solo *"Run a `/grilling` session"*, y `grilling` (que también instalo) ya es autoinvocable. Así que para grillar a mitad de prompt, encadenado o desde un handoff, invoca `/grilling` directamente; `/grill-me` queda como punto de entrada explícito, lo primero del prompt.

```bash
npx skills add mattpocock/skills --skill …   # instala verbatim
./scripts/patch-matt-skills.sh               # reaplica mi preferencia
```

## `check-upstream`

Como las skills de Matt van evolucionando, llevo una skill de proyecto, **`check-upstream`** (en [`.claude/skills/`](.claude/skills/check-upstream/)), que audita su repo y mantiene al día mi manifiesto ([`upstream/matt-skills.json`](upstream/matt-skills.json)). No es instalable por otros, sino la mecánica con la que vigilo si sus skills se han movido respecto a las que tengo registradas; por eso no aparece en los comandos de instalación.

## Créditos

Las skills de Matt Pocock que uso en el flujo son obra suya y viven en [github.com/mattpocock/skills](https://github.com/mattpocock/skills). Todo el crédito de ese trabajo es suyo. Mi aporte es el flujo, mis 4 skills del loop HITL (`build`, `improve`, `commit`, `coding-standards`) y tratar de acercar todo esto a la comunidad hispanohablante.

`zoom-out` también nació suya. Matt la retiró de su upstream, así que la adopté y ahora la mantengo aquí (en [`skills/zoom-out/`](skills/zoom-out/)); el crédito de la idea sigue siendo suyo.

Gracias a Matt por estas skills y por ser de los pocos que defienden de verdad usar la IA sin bajar el listón. Buena parte de mi flujo no existiría sin su trabajo.

## Licencia

[MIT](LICENSE) © 2026 Noel López.
