import {
  createTypeSpecLibrary,
  DecoratorContext,
  Namespace,
  Operation,
  paramMessage,
  StringLiteral,
} from "@typespec/compiler";

export const $lib = createTypeSpecLibrary({
  name: "@murbagus/typespec-domaingin-emitter",
  diagnostics: {
    "invalid-handler-name": {
      severity: "error",
      messages: {
        default: paramMessage`Handler name must be a string, got ${"type"}`,
      },
    },
  },
} as const);

const handlerNameKey = Symbol("domainGinHandlerName");
const handlerGenKey = Symbol("domainGinHandlerGen");

/**
 * Set the handler name for Gin domain handler generation
 * @param context Decorator context
 * @param target Target namespace or operation
 * @param handlerName Name of the handler struct (e.g., "User" for "func (h *User)")
 */
export function $domainGinHandlerName(
  context: DecoratorContext,
  target: Namespace | Operation,
  handlerName: StringLiteral
) {
  if (handlerName.kind !== "String") {
    context.program.reportDiagnostic(
      $lib.createDiagnostic({
        code: "invalid-handler-name",
        target: context.decoratorTarget,
        format: { type: handlerName.kind },
      })
    );
    return;
  }

  context.program.stateMap(handlerNameKey).set(target, handlerName.value);
}

/**
 * Mark namespace or operation for Gin handler generation
 * @param context Decorator context
 * @param target Target namespace or operation
 */
export function $domainGinHandlerGen(
  context: DecoratorContext,
  target: Namespace | Operation
) {
  context.program.stateMap(handlerGenKey).set(target, true);
}

/**
 * Get the handler name for a namespace or operation
 * @param program TypeSpec program
 * @param target Target namespace or operation
 * @returns Handler name or undefined
 */
export function getDomainGinHandlerName(
  program: any,
  target: Namespace | Operation
): string | undefined {
  return program.stateMap(handlerNameKey).get(target);
}

/**
 * Check if a namespace or operation is marked for handler generation
 * @param program TypeSpec program
 * @param target Target namespace or operation
 * @returns True if marked for generation
 */
export function isDomainGinHandlerGen(
  program: any,
  target: Namespace | Operation
): boolean {
  return program.stateMap(handlerGenKey).has(target);
}
