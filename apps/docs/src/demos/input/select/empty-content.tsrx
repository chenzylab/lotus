import { Select } from '@lotus/ripple';

export function SelectEmptyContentDemo() {
    return <Select optionList={[]} emptyContent="暂无可选项" placeholder="请选择" />;
}
