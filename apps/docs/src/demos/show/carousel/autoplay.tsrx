import { Carousel, TypographyText } from '@lotus/ripple';

function slide(bg: string, text: string) {
    return <div style={{ width: '100%', height: '100%', background: bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <TypographyText style={{ color: '#fff', fontSize: '20px' }}>{text}</TypographyText>
    </div>;
}

export function AutoplayCarouselDemo() @{
    <div style={{ width: '400px', height: '200px' }}>
        <Carousel
            items={[
                slide('var(--lotus-color-primary)', '自动播放 1'),
                slide('var(--lotus-color-danger)', '自动播放 2'),
            ]}
            autoPlay={{ interval: 1500, hoverToPause: true }}
            indicatorType="line"
            aria-label="Carousel 自动播放"
        />
    </div>
}
