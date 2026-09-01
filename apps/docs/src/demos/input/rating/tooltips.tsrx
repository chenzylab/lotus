import { Rating } from '@lotus/ripple';

export function RatingTooltipsDemo() {
    return (
        <Rating
            tooltips={['terrible', 'bad', 'normal', 'good', 'great']}
            aria-label="带提示文案的评分"
        />
    );
}
