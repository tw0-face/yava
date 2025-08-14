import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
    vus: 10,
    duration: '10s',
};
export default function () {
    http.post('http://vote.voting-app/', 'vote=a', {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  });
    sleep(1);
}