import type { BytemdPlugin, BytemdAction, EditorProps, BytemdLocale, BytemdEditorContext } from './types';
import type { Editor, Position } from 'codemirror';
import type CodeMirror from 'codemirror';
export declare function createCodeMirror(): typeof CodeMirror;
export type EditorUtils = ReturnType<typeof createEditorUtils>;
export declare function createEditorUtils(codemirror: typeof CodeMirror, editor: Editor): {
    /**
     * Wrap text with decorators, for example:
     *
     * `text -> *text*`
     */
    wrapText(before: string, after?: string): void;
    /**
     * replace multiple lines
     *
     * `line -> # line`
     */
    replaceLines(replace: Parameters<Array<string>['map']>[0]): void;
    /**
     * Append a block based on the cursor position
     */
    appendBlock(content: string): Position;
    /**
     * Triggers a virtual file input and let user select files
     *
     * https://www.npmjs.com/package/select-files
     */
    selectFiles: (options?: import("select-files").Options | undefined) => Promise<FileList | null>;
};
export declare function findStartIndex(num: number, nums: number[]): number;
export declare function handleImageUpload({ editor, appendBlock, codemirror }: BytemdEditorContext, uploadImages: NonNullable<EditorProps['uploadImages']>, files: File[]): Promise<void>;
export declare function getBuiltinActions(locale: BytemdLocale, plugins: BytemdPlugin[], uploadImages: EditorProps['uploadImages']): {
    leftActions: BytemdAction[];
    rightActions: BytemdAction[];
};
