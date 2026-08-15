import { Dropdown, DropdownMenu, DropdownItem, DropdownTitle, DropdownDivider, Button } from '@lotus/ripple';

export function DropdownNestedDemo() {
    return <Dropdown
        trigger="click"
        render={
            <DropdownMenu>
                <DropdownTitle>分组一</DropdownTitle>
                <DropdownItem>选项一</DropdownItem>
                <DropdownItem>选项二</DropdownItem>
                <DropdownDivider />
                <DropdownTitle>分组二</DropdownTitle>
                <DropdownItem>选项三</DropdownItem>
            </DropdownMenu>
        }
    >
        <Button theme="outline">分组菜单</Button>
    </Dropdown>;
}
