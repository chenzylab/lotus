import { track, untrack, effect } from 'ripple';
import { FormContext } from './form-context.js';

/**
 * Form.ArrayField：动态增删的字段数组（对齐 Semi Form.ArrayField），常见于
 * "批量添加联系人"一类场景。formState.values[field] 存一个数组，每一项对应
 * 一行，行内字段名用 `${field}[${index}]` 拼接（如 `contacts[0].name`），
 * 供内部正常的 `<Field>` 注册消费。
 *
 * 简化于 Semi 源码：不做 Semi 内部那套 updateKey 时间戳机制去区分"外部
 * setValues 触发的重新挂载"与"用户操作 add/remove 触发的重新挂载"——改为
 * 直接响应式监听 `state.values[field]` 数组长度变化来同步 `keys` 长度，
 * 复用 Ripple track() 本身的响应式能力，不需要额外的脏检测时间戳。
 * `key` 用递增计数器而非 uuid（同一浏览器会话内保证唯一即可，不需要
 * 跨会话/跨进程唯一性）。
 *
 * remove(index) 必须把 index 及其后所有行的 key 换成全新值，不能保留旧
 * key 让 Ripple 认为"同一行只是挪了位置"——真机验证 + 阅读 Ripple 编译器/
 * 运行时源码（tsrx-ripple 的组件调用走 `_$_.render_component`，只在
 * `@for` 的 `create_item` 首次创建 block 时调用一次；`for.js` 的 keyed
 * 复用分支 `update_value` 只更新循环变量 item 本身的 tracked signal，不会
 * 重新调用 render_fn）证实：`<Field field={item.field} />` 这种"组件调用
 * 而非 DOM 元素"的 props 对象只在组件创建时构造一次，之后 key 相同触发的
 * 复用不会让 Field 重新读取新的 field prop——若中间行被删除、后面的行
 * 沿用旧 key"挪位置"，Ripple 会复用旧 Field 实例，实例内部的 value 仍停
 * 留在旧 field 路径最后一次读到的值，界面上表现为数据错位/丢失。换新 key
 * 强制 Ripple 走 `create_item` 销毁重建，Field 重新 mount 时才会用新
 * field 路径重新 registerField + 重新读取当前值，这是唯一能绕过该框架
 * 限制的方式（对应地放弃了"删除时后续行 DOM 节点被稳定复用"这一优化，
 * 换来数据正确性——ArrayField 增删本就是低频操作，这个取舍合理）。
 */
export interface ArrayFieldRenderProps {
    arrayFields: Array<{ key: string; field: string; remove: () => void }>;
    add: (index?: number) => void;
    addWithInitValue: (rowValue: unknown, index?: number) => void;
}

export interface ArrayFieldProps {
    /** 该数组字段在 formState.values 中的 key，必填。 */
    field: string;
    /** 非受控模式下的初始数组值，仅在挂载时消费一次。 */
    initValue?: unknown[];
    /** 实际渲染内容，以“组件作为显式 prop”的方式传入（同 Field 的 Comp
     * 模式）——Ripple 没有 render-prop/函数调用 children 的机制，组件只能
     * 作为 prop 传递并用 `<Comp {...} />` 渲染，不能当函数调用（真机验证
     * 踩过这个坑：早期实现把它当函数调用 `render({...})` 直接插值，
     * ArrayField 内部产出的 arrayFields 传不到子级 Field，全部渲染出
     * undefined 的 field 名——同 ColorPicker 的 ColorPickerTrigger 是
     * 已知的同一类边界情况）。该组件会收到 { arrayFields, add,
     * addWithInitValue }。 */
    Comp: (props: ArrayFieldRenderProps) => any;
}

let arrayFieldKeyCounter = 0;

export function ArrayField(&{ field, initValue, Comp }: ArrayFieldProps) @{
    const contextTracked = FormContext.get();
    const foundation = contextTracked?.value.foundation;

    const existingValue = foundation?.getValue(field);
    const initialArray = Array.isArray(initValue)
        ? initValue
        : (Array.isArray(existingValue) ? (existingValue as unknown[]) : []);

    foundation?.registerField(field, {}, initValue !== undefined ? initValue : undefined);

    // 推迟到微任务执行——同 field.tsrx 的 unregisterField 处理，避免在
    // effect cleanup 的 teardown 上下文里读到 Ripple old_values 锁定的
    // 过期 state 快照（详见 field.tsrx 对应注释）。
    effect(() => {
        return () => queueMicrotask(() => foundation?.unregisterField(field));
    });

    let &[keys] = track<string[]>(() => initialArray.map(() => String(arrayFieldKeyCounter++)));

    // 本组件自身触发的增删（add/addWithInitValue/remove）已经在各自的处理
    // 函数里同步维护了 keys，不依赖这个 effect 兜底——只用于捕获"外部通过
    // formApi.setValue/setValues 绕过 add/remove 直接改变数组长度"的场景，
    // 此时按标记位区分来源，直接整体重新生成全部 key（不复用任何旧
    // key，同 remove() 的取舍：换新 key 强制 Ripple 重新创建 Field 而非
    // 复用出错位的旧实例，见文件头注释）。
    let lastKnownLength = untrack(() => keys).length;
    let selfTriggeredChange = false;
    effect(() => {
        const currentValues = contextTracked?.value.state ? foundation?.getValue(field) : undefined;
        const length = Array.isArray(currentValues) ? currentValues.length : 0;
        if (untrack(() => selfTriggeredChange)) {
            untrack(() => { selfTriggeredChange = false; lastKnownLength = length; });
            return;
        }
        if (length === untrack(() => lastKnownLength)) return;
        untrack(() => {
            lastKnownLength = length;
            keys = Array.from({ length }, () => String(arrayFieldKeyCounter++));
        });
    });

    function getArrayValue(): unknown[] {
        const currentValues = untrack(() => foundation?.getValue(field));
        return Array.isArray(currentValues) ? currentValues : [];
    }

    function add(index?: number) {
        const current = getArrayValue();
        const nextValues = current.slice();
        const insertAt = typeof index === 'number' ? Math.max(0, Math.min(index, current.length)) : current.length;
        nextValues.splice(insertAt, 0, undefined);
        untrack(() => { selfTriggeredChange = true; });
        foundation?.setValue(field, nextValues, contextTracked?.value.onValueChange);
        // 插入点之后的行，其 field 路径（`${field}[${index}]`）全部整体后移
        // 了一位——同 remove() 的道理，必须连带换新 key 强制这些行的 Field
        // 重新创建，不能只在数组头部插入一个新 key 而让后面的行继续沿用
        // 旧 key（那样会复用出与 remove() 完全相同的错位 bug）。
        const currentKeys = untrack(() => keys);
        const nextKeys = [
            ...currentKeys.slice(0, insertAt),
            String(arrayFieldKeyCounter++),
            ...currentKeys.slice(insertAt).map(() => String(arrayFieldKeyCounter++)),
        ];
        untrack(() => { keys = nextKeys; });
    }

    function addWithInitValue(rowValue: unknown, index?: number) {
        const current = getArrayValue();
        const nextValues = current.slice();
        const insertAt = typeof index === 'number' ? Math.max(0, Math.min(index, current.length)) : current.length;
        nextValues.splice(insertAt, 0, rowValue);
        untrack(() => { selfTriggeredChange = true; });
        foundation?.setValue(field, nextValues, contextTracked?.value.onValueChange);
        const currentKeys = untrack(() => keys);
        const nextKeys = [
            ...currentKeys.slice(0, insertAt),
            String(arrayFieldKeyCounter++),
            ...currentKeys.slice(insertAt).map(() => String(arrayFieldKeyCounter++)),
        ];
        untrack(() => { keys = nextKeys; });
    }

    function remove(index: number) {
        const current = getArrayValue();
        const nextValues = current.slice();
        nextValues.splice(index, 1);
        untrack(() => { selfTriggeredChange = true; });
        foundation?.setValue(field, nextValues, contextTracked?.value.onValueChange);
        // 删除位置之后的行，其 field 路径全部整体前移了一位——不能保留这些
        // 行原来的 key（那样 Ripple 会复用旧 Field 实例、其 value 停留在
        // 旧路径最后一次读到的值，界面上表现为数据错位/丢失，见文件头
        // 注释的框架限制说明），全部换新 key 强制重新创建。
        const currentKeys = untrack(() => keys);
        const nextKeys = [
            ...currentKeys.slice(0, index),
            ...currentKeys.slice(index + 1).map(() => String(arrayFieldKeyCounter++)),
        ];
        untrack(() => { keys = nextKeys; });
    }

    let &[arrayFields] = track<Array<{ key: string; field: string; remove: () => void }>>(() =>
        keys.map((key, index) => ({ key, field: `${field}[${index}]`, remove: () => remove(index) })),
    );

    <Comp arrayFields={arrayFields} add={add} addWithInitValue={addWithInitValue} />
}
