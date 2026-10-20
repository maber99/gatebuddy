import type de from './de';

/** Gleiche Struktur wie die deutsche Vorlage; Werte sind beliebige Texte. */
type Widen<T> = T extends string
  ? string
  : T extends readonly (infer U)[]
    ? Widen<U>[]
    : { [K in keyof T]: Widen<T[K]> };

export type Translation = Widen<typeof de>;
