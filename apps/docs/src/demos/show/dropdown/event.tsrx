import { Dropdown, DropdownMenu, DropdownItem, Button } from '@lotus/ripple';
import { IconToken } from '@lotus/icons-lab';

export function DropdownEventDemo() {
    return <Dropdown
        trigger="click"
        position="bottomLeft"
        render={
            <DropdownMenu>
                <DropdownItem onClick={() => console.log('1: click me!')}>1: click me!</DropdownItem>
                <DropdownItem onMouseEnter={() => console.log('2: mouse enter')}>2: mouse enter</DropdownItem>
                <DropdownItem onMouseLeave={() => console.log('3: mouse leave')}>3: mouse leave</DropdownItem>
                <DropdownItem onContextMenu={() => console.log('4: right clicked!')}>4: right click</DropdownItem>
            </DropdownMenu>
        }
    >
        <Button theme="outline" type="tertiary" icon={<IconToken />}>Click Me</Button>
    </Dropdown>;
}
