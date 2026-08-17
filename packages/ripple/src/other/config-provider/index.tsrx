import { track } from 'ripple';
import { zhCN, type LocaleShape } from '@lotus/locale';
import { LocaleContext } from './locale-context.js';

export interface ConfigProviderProps {
    /** 子树内所有组件消费的语言包，默认中文简体。切换该 prop 会让子树内
     * 组件的文案（包括 Form 校验错误信息）实时更新，不需要重新挂载——
     * 因为文案读取走响应式 Context，不是挂载时读取一次的静态值。 */
    locale?: LocaleShape;
    children?: any;
}

export function ConfigProvider(&{ locale = zhCN, children }: ConfigProviderProps) @{
    let &[, localeTracked] = track<LocaleShape>(() => locale);
    LocaleContext.set(localeTracked);

    <>{children}</>
}
