import { Carousel, TypographyText } from '@lotus/ripple';

function slide(bg: string, text: string) {
    return <div style={{ width: '100%', height: '100%', background: bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <TypographyText style={{ color: '#fff', fontSize: '20px' }}>{text}</TypographyText>
    </div>;
}

export function BasicCarouselDemo() @{
    <div style={{ width: '400px', height: '200px' }}>
        <Carousel
            items={[
                slide('var(--lotus-color-primary)', '第一张'),
                slide('var(--lotus-color-success)', '第二张'),
                slide('var(--lotus-color-warning)', '第三张'),
            ]}
            autoPlay={false}
            aria-label="Carousel 基础用法"
        />
    </div>
}
