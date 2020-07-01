export default function formatCurrency(value) {
  return value
    .toLocaleString('en-US', {
      currency: 'USD',
      style: 'currency',
    })
    .replace('$', '')
    .replace('.00', '')
}
