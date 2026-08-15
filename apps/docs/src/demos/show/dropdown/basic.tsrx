import { Dropdown, DropdownMenu, DropdownItem, Button } from '@lotus/ripple';

export function DropdownBasicDemo() {
    return <Dropdown
        trigger="click"
        render={
            <DropdownMenu>
                <DropdownItem>选项一</DropdownItem>
                <DropdownItem>选项二</DropdownItem>
                <DropdownItem type="danger">删除</DropdownItem>
            </DropdownMenu>
        }
    >
        <Button theme="outline">点击展开菜单</Button>
    </Dropdown>;
}
