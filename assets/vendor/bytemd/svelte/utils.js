import { defaultSchema } from 'hast-util-sanitize';
import rehypeRaw from 'rehype-raw';
import rehypeSanitize from 'rehype-sanitize';
import rehypeStringify from 'rehype-stringify';
import remarkParse from 'remark-parse';
import remarkRehype from 'remark-rehype';
import { unified } from 'unified';
const schemaStr = JSON.stringify(defaultSchema);
/**
 * Get unified processor with ByteMD plugins
 */
export function getProcessor({ sanitize, plugins, remarkRehype: remarkRehypeOptions = {}, }) {
    let processor = unified().use(remarkParse);
    plugins?.forEach(({ remark }) => {
        if (remark)
            processor = remark(processor);
    });
    processor = processor
        .use(remarkRehype, { allowDangerousHtml: true, ...remarkRehypeOptions })
        .use(rehypeRaw);
    let schema = JSON.parse(schemaStr);
    schema.attributes['*'].push('className'); // Allow class names by default
    if (typeof sanitize === 'function') {
        schema = sanitize(schema);
    }
    processor = processor.use(rehypeSanitize, schema);
    plugins?.forEach(({ rehype }) => {
        if (rehype)
            processor = rehype(processor);
    });
    return processor.use(rehypeStringify);
}
