import type { ViewerProps } from './types';
import type { Processor } from 'unified';
/**
 * Get unified processor with ByteMD plugins
 */
export declare function getProcessor({ sanitize, plugins, remarkRehype: remarkRehypeOptions, }: Omit<ViewerProps, 'value'>): Processor<import("hast").Root, import("hast").Root, import("hast").Root, string>;
