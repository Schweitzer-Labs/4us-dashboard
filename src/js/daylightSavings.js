Date.prototype.stdTimezoneOffset = function() {
    const jan = new Date(this.getFullYear(), 0, 1);
    const jul = new Date(this.getFullYear(), 6, 1);

   return Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset())
}

Date.prototype.isDstObserved = function ()  { return this.getTimezoneOffset() < this.stdTimezoneOffset() }


const today = new Date();


export const getDST = () =>  today.isDstObserved()



